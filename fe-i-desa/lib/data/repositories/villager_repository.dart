import 'package:uuid/uuid.dart';

import '../models/pending_mutation.dart';
import '../models/villager.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/mock_api_service.dart';
import '../services/write_queue_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class VillagerRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();
  final CacheService _cache = CacheService();
  final WriteQueueService _queue = WriteQueueService();
  final AuthService _authService = AuthService();
  static const _uuid = Uuid();

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  /// See [FamilyCardRepository._queueIfOffline] — same idea, villager domain.
  Future<PendingMutation?> _queueIfOffline(
    Object e, {
    required MutationOp op,
    required String nik,
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    if (!CacheService.isOffline(e)) return null;
    final villageId = await _authService.getVillageId();
    if (villageId == null || villageId.isEmpty) return null;

    final mutation = PendingMutation(
      id: _uuid.v4(),
      domain: MutationDomain.villager,
      op: op,
      entityKey: nik,
      method: method,
      path: path,
      body: body,
      villageId: villageId,
      queuedAt: DateTime.now(),
    );
    await _queue.enqueue(mutation);
    return mutation;
  }

  /// Patches the cached family-card detail (`family_members`, written by
  /// `FamilyCardRepository.getFamilyCardDetail`) so a resident's
  /// create/update/delete is visible immediately even while still offline.
  /// A no-op if [familyCardId] is unknown or nothing is cached yet for it —
  /// best-effort UX only, not required for the queue itself to be correct.
  Future<void> _patchFamilyMembersCache(
    String? familyCardId,
    MutationOp op,
    String nik, {
    Villager? createdVillager,
    Map<String, dynamic>? updateFields,
  }) async {
    if (familyCardId == null || familyCardId.isEmpty) return;
    final cached = await _cache.read(CacheKeys.familyCardDetail(familyCardId));
    if (cached == null) return;

    final detail = Map<String, dynamic>.from(cached.data as Map<String, dynamic>);
    final members = ((detail['family_members'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .toList();

    switch (op) {
      case MutationOp.create:
        if (createdVillager == null) break;
        final age = DateTime.now().difference(createdVillager.tanggalLahir).inDays ~/ 365;
        members.add({
          'nik': createdVillager.nik,
          'name': createdVillager.namaLengkap,
          'status_hubungan': createdVillager.statusHubungan,
          'age': age,
          'jenis_kelamin': createdVillager.jenisKelamin,
          'pendidikan': createdVillager.pendidikan,
          'pekerjaan': createdVillager.pekerjaan,
        });
        break;
      case MutationOp.update:
        final index = members.indexWhere((m) => m['nik'] == nik);
        if (index != -1 && updateFields != null) {
          members[index] = {...members[index], ..._toMemberFields(updateFields)};
        }
        break;
      case MutationOp.delete:
        members.removeWhere((m) => m['nik'] == nik);
        break;
    }

    detail['family_members'] = members;
    await _cache.write(CacheKeys.familyCardDetail(familyCardId), detail);
  }

  /// Translates the partial-update request payload's field names (matching
  /// `UpdateVillagerRequest`, e.g. `nama_lengkap`) to the cached member's
  /// field names (matching the BE's `GetFamilyMember` response DTO, e.g.
  /// `name`) — the two shapes differ because one is a request body and the
  /// other a summary read from a different endpoint.
  Map<String, dynamic> _toMemberFields(Map<String, dynamic> data) {
    const keyMap = {
      'nama_lengkap': 'name',
      'status_hubungan': 'status_hubungan',
      'jenis_kelamin': 'jenis_kelamin',
      'pendidikan': 'pendidikan',
      'pekerjaan': 'pekerjaan',
    };
    final result = <String, dynamic>{};
    for (final entry in keyMap.entries) {
      if (data.containsKey(entry.key)) result[entry.value] = data[entry.key];
    }
    return result;
  }

  Future<List<Villager>> getAllVillagers({int page = 1, int limit = 100}) async {
    return (await _fetchVillagerPage(page: page, limit: limit)).villagers;
  }

  /// Fetches every resident across all pages, using the `pagination.total_pages`
  /// the backend now reports (added alongside real LIMIT/OFFSET support) to
  /// know exactly how many requests to make.
  ///
  /// Falls back to a single page — via [seenNiks]/[maxPages] as a last-resort
  /// safety net rather than trusting `total_pages` blindly — if a response
  /// ever omits pagination metadata (e.g. the mock API, which returns
  /// everything in one unpaginated response).
  Future<List<Villager>> getAllVillagersAcrossPages({int pageSize = 100}) async {
    final first = await _fetchVillagerPage(page: 1, limit: pageSize);
    final all = <Villager>[...first.villagers];
    if (first.totalPages == null || first.totalPages! <= 1) {
      return all;
    }

    final seenNiks = all.map((v) => v.nik).toSet();
    const maxPages = 200;
    final lastPage = first.totalPages! > maxPages ? maxPages : first.totalPages!;

    for (var page = 2; page <= lastPage; page++) {
      final next = await _fetchVillagerPage(page: page, limit: pageSize);
      if (next.villagers.isEmpty) break;

      var addedNew = false;
      for (final v in next.villagers) {
        if (seenNiks.add(v.nik)) {
          all.add(v);
          addedNew = true;
        }
      }
      if (!addedNew) break;
    }

    return all;
  }

  Future<({List<Villager> villagers, int? totalPages})> _fetchVillagerPage({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.villagers,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List rawList = [];
        int? totalPages;
        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          rawList = (data['data'] ?? data['villagers'] ?? []) as List;
          final pagination = data['pagination'];
          if (pagination is Map<String, dynamic>) {
            totalPages = (pagination['total_pages'] as num?)?.toInt();
          }
        }

        final villagers = <Villager>[];
        for (final item in rawList) {
          try {
            if (item is Map<String, dynamic>) {
              villagers.add(Villager.fromJson(item));
            }
          } catch (e) {
            print('Error parsing villager item: $e');
          }
        }
        return (villagers: villagers, totalPages: totalPages);
      }
      return (villagers: <Villager>[], totalPages: null);
    } catch (e) {
      print('Error fetching villagers: ${ApiService.getErrorMessage(e)}');
      return (villagers: <Villager>[], totalPages: null);
    }
  }

  /// Full record for one resident.
  ///
  /// The family-card detail response only carries a few fields per member, so
  /// the edit form opened from there had blank birth date, religion, marital
  /// status and so on — the operator had to retype data that already existed.
  /// This endpoint returns everything.
  Future<Map<String, dynamic>?> getVillagerByNik(String nik) async {
    try {
      final response = await _api.get(ApiConstants.villagerByNik(nik));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching villager: ${ApiService.getErrorMessage(e)}');
      return null;
    }
  }

  Future<Map<String, dynamic>> createVillager(Villager villager) async {
    try {
      final response = await _api.post(
        ApiConstants.villagers,
        data: villager.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Penduduk berhasil ditambahkan',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menambahkan penduduk'),
        };
      }
    } catch (e) {
      final queued = await _queueIfOffline(
        e,
        op: MutationOp.create,
        nik: villager.nik,
        method: 'POST',
        path: ApiConstants.villagers,
        body: villager.toJson(),
      );
      if (queued != null) {
        await _patchFamilyMembersCache(
          villager.familyCardId,
          MutationOp.create,
          villager.nik,
          createdVillager: villager,
        );
        return {
          'success': true,
          'queued': true,
          'message': 'Penduduk disimpan secara lokal. Akan otomatis dikirim saat online.',
        };
      }
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  /// [familyCardId] is optional — pass it when the caller has it in scope
  /// (it isn't part of the partial-update payload itself) so an offline
  /// update can also patch that family's cached detail view immediately.
  Future<Map<String, dynamic>> updateVillager(
    String nik,
    Map<String, dynamic> data, {
    String? familyCardId,
  }) async {
    try {
      final response = await _api.put(
        ApiConstants.villagerByNik(nik),
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Penduduk berhasil diperbarui',
        };
      } else {
        final responseData = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(responseData, fallback: 'Gagal memperbarui penduduk'),
        };
      }
    } catch (e) {
      final queued = await _queueIfOffline(
        e,
        op: MutationOp.update,
        nik: nik,
        method: 'PUT',
        path: ApiConstants.villagerByNik(nik),
        body: data,
      );
      if (queued != null) {
        await _patchFamilyMembersCache(familyCardId, MutationOp.update, nik, updateFields: data);
        return {
          'success': true,
          'queued': true,
          'message': 'Perubahan disimpan secara lokal. Akan otomatis dikirim saat online.',
        };
      }
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  /// See [updateVillager] re: [familyCardId].
  Future<Map<String, dynamic>> deleteVillager(String nik, {String? familyCardId}) async {
    try {
      final response = await _api.delete(
        ApiConstants.villagerByNik(nik),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Penduduk berhasil dihapus',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menghapus penduduk'),
        };
      }
    } catch (e) {
      final queued = await _queueIfOffline(
        e,
        op: MutationOp.delete,
        nik: nik,
        method: 'DELETE',
        path: ApiConstants.villagerByNik(nik),
      );
      if (queued != null) {
        await _patchFamilyMembersCache(familyCardId, MutationOp.delete, nik);
        return {
          'success': true,
          'queued': true,
          'message': 'Penghapusan disimpan secara lokal. Akan otomatis dikirim saat online.',
        };
      }
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }
}
