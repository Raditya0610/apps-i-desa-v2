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
    try {
      final response = await _api.get(
        ApiConstants.villagers,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List rawList = [];
        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          rawList = (data['data'] ?? data['villagers'] ?? []) as List;
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
        return villagers;
      }
      return [];
    } catch (e) {
      print('Error fetching villagers: ${ApiService.getErrorMessage(e)}');
      return [];
    }
  }

  /// Fetches every resident across all pages.
  ///
  /// [getAllVillagers] only returns one page (100 rows by default) — screens
  /// that need the whole village, like the dashboard's demographic
  /// breakdowns, were silently dropping every resident past #100. Stops once
  /// a page comes back short of [pageSize], with a hard cap so a backend that
  /// never returns a short page can't spin this forever.
  Future<List<Villager>> getAllVillagersAcrossPages({int pageSize = 100}) async {
    final all = <Villager>[];
    var page = 1;
    const maxPages = 500;

    while (page <= maxPages) {
      final batch = await getAllVillagers(page: page, limit: pageSize);
      all.addAll(batch);
      if (batch.length < pageSize) break;
      page++;
    }

    return all;
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
