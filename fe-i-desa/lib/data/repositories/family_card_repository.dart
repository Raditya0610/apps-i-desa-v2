import 'package:uuid/uuid.dart';

import '../models/cached_result.dart';
import '../models/family_card.dart';
import '../models/family_card_detail.dart';
import '../models/pending_mutation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/mock_api_service.dart';
import '../services/write_queue_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class FamilyCardRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();
  final CacheService _cache = CacheService();
  final WriteQueueService _queue = WriteQueueService();
  final AuthService _authService = AuthService();
  static const _uuid = Uuid();

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  /// Queues [op] for later replay if we're currently offline (per
  /// [CacheService.isOffline]). Returns null if [e] was a real rejection
  /// (not a connectivity failure), or if there's no authenticated village to
  /// scope the entry to — the caller should fall through to the normal
  /// failure path in that case.
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
      domain: MutationDomain.familyCard,
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

  /// Patches the cached family-card list so it reflects [op] immediately,
  /// even while still offline — reuses the same read-cache-fallback that
  /// [getAllFamilyCards] already falls back to, rather than a new merge
  /// layer in every screen that lists family cards.
  Future<void> _patchListCache(
    MutationOp op,
    String nik, {
    Map<String, dynamic>? createJson,
    Map<String, dynamic>? updateFields,
  }) async {
    final cached = await _cache.read(CacheKeys.familyCards);
    if (cached == null) return;
    final list = (cached.data as List).cast<Map<String, dynamic>>().toList();

    switch (op) {
      case MutationOp.create:
        list.add({
          'nik': nik,
          'name': '',
          'total_members': 0,
          ...?createJson,
        });
        break;
      case MutationOp.update:
        final index = list.indexWhere((item) => item['nik'] == nik);
        if (index != -1) list[index] = {...list[index], ...?updateFields};
        break;
      case MutationOp.delete:
        list.removeWhere((item) => item['nik'] == nik);
        break;
    }

    await _cache.write(CacheKeys.familyCards, list);
  }

  /// Same idea as [_patchListCache] but for the single-record detail cache
  /// (`getFamilyCardDetail`) — only relevant for updates; a fresh create has
  /// no prior detail cached yet, and there's no per-key cache removal to
  /// clean up after a delete (harmless staleness if that exact detail page
  /// is revisited offline before the next sync).
  Future<void> _patchDetailCache(String nik, Map<String, dynamic> updateFields) async {
    final cached = await _cache.read(CacheKeys.familyCardDetail(nik));
    if (cached == null) return;
    final detail = {...(cached.data as Map<String, dynamic>), ...updateFields};
    await _cache.write(CacheKeys.familyCardDetail(nik), detail);
  }

  Future<CachedResult<List<FamilyCard>>> getAllFamilyCards() async {
    try {
      final response = await _api.get(ApiConstants.familyCards);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final familyCards = data['family_cards'] as List;
        if (!AppConfig.useMockApi) {
          await _cache.write(CacheKeys.familyCards, familyCards);
        }
        return CachedResult.fresh(_parseFamilyCards(familyCards));
      }
      return const CachedResult.fresh([]);
    } catch (e) {
      print('Error fetching family cards: ${ApiService.getErrorMessage(e)}');

      if (CacheService.isOffline(e)) {
        final cached = await _cache.read(CacheKeys.familyCards);
        if (cached != null) {
          print('Serving family cards from cache (${cached.cachedAt})');
          return CachedResult.fromCache(
            _parseFamilyCards(cached.data as List),
            cached.cachedAt,
          );
        }
      }

      return const CachedResult.fresh([]);
    }
  }

  List<FamilyCard> _parseFamilyCards(List json) => json
      .map((e) => FamilyCard.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<FamilyCard?> getFamilyCardById(String nik) async {
    try {
      final response = await _api.get(
        ApiConstants.familyCardById(nik),
      );

      if (response.statusCode == 200) {
        return FamilyCard.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching family card: ${ApiService.getErrorMessage(e)}');
      return null;
    }
  }

  Future<CachedResult<FamilyCardDetail?>> getFamilyCardDetail(String nik) async {
    try {
      final response = await _api.get(
        ApiConstants.familyCardById(nik),
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (!AppConfig.useMockApi) {
          await _cache.write(CacheKeys.familyCardDetail(nik), json);
        }
        return CachedResult.fresh(FamilyCardDetail.fromJson(json));
      }
      return const CachedResult.fresh(null);
    } catch (e) {
      print('Error fetching family card detail: ${ApiService.getErrorMessage(e)}');

      if (CacheService.isOffline(e)) {
        final cached = await _cache.read(CacheKeys.familyCardDetail(nik));
        if (cached != null) {
          print('Serving family card $nik from cache (${cached.cachedAt})');
          return CachedResult.fromCache(
            FamilyCardDetail.fromJson(cached.data as Map<String, dynamic>),
            cached.cachedAt,
          );
        }
      }

      return const CachedResult.fresh(null);
    }
  }

  Future<Map<String, dynamic>> deleteFamilyCard(String nik) async {
    try {
      final response = await _api.delete(ApiConstants.familyCardById(nik));
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kartu keluarga berhasil dihapus',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menghapus kartu keluarga'),
        };
      }
    } catch (e) {
      final queued = await _queueIfOffline(
        e,
        op: MutationOp.delete,
        nik: nik,
        method: 'DELETE',
        path: ApiConstants.familyCardById(nik),
      );
      if (queued != null) {
        await _patchListCache(MutationOp.delete, nik);
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

  Future<Map<String, dynamic>> updateFamilyCard(
    String nik,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.put(
        ApiConstants.familyCardById(nik),
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kartu keluarga berhasil diperbarui',
        };
      } else {
        final responseData = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(responseData, fallback: 'Gagal memperbarui kartu keluarga'),
        };
      }
    } catch (e) {
      final queued = await _queueIfOffline(
        e,
        op: MutationOp.update,
        nik: nik,
        method: 'PUT',
        path: ApiConstants.familyCardById(nik),
        body: data,
      );
      if (queued != null) {
        await _patchListCache(MutationOp.update, nik, updateFields: data);
        await _patchDetailCache(nik, data);
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

  Future<Map<String, dynamic>> createFamilyCard(FamilyCard familyCard) async {
    try {
      final response = await _api.post(
        ApiConstants.familyCards,
        data: familyCard.toCreateJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kartu keluarga berhasil ditambahkan',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menambahkan kartu keluarga'),
        };
      }
    } catch (e) {
      final queued = await _queueIfOffline(
        e,
        op: MutationOp.create,
        nik: familyCard.nik,
        method: 'POST',
        path: ApiConstants.familyCards,
        body: familyCard.toCreateJson(),
      );
      if (queued != null) {
        await _patchListCache(MutationOp.create, familyCard.nik, createJson: familyCard.toCreateJson());
        return {
          'success': true,
          'queued': true,
          'message': 'Kartu keluarga disimpan secara lokal. Akan otomatis dikirim saat online.',
        };
      }
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }
}
