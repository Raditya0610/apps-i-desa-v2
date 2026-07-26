import '../models/villager.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class VillagerRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

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
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> updateVillager(
    String nik,
    Map<String, dynamic> data,
  ) async {
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
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> deleteVillager(String nik) async {
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
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }
}
