import '../models/cached_result.dart';
import '../models/dashboard.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/mock_api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();
  final CacheService _cache = CacheService();

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  Future<CachedResult<Dashboard?>> getDashboard() async {
    try {
      final response = await _api.get(ApiConstants.dashboard);

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (!AppConfig.useMockApi) {
          await _cache.write(CacheKeys.dashboard, json);
        }
        return CachedResult.fresh(Dashboard.fromJson(json));
      }
      return const CachedResult.fresh(null);
    } catch (e) {
      final errorMessage = ApiService.getErrorMessage(e);
      print('Error fetching dashboard: $errorMessage');

      // If the error is about missing data (no residents yet), return empty dashboard
      if (errorMessage.contains('average age') ||
          errorMessage.contains('Failed to get') ||
          errorMessage.toLowerCase().contains('no data')) {
        print('Returning empty dashboard for new village with no data');
        return CachedResult.fresh(Dashboard(
          totalKeluarga: 0,
          totalPenduduk: 0,
          rerataKeluarga: 0.0,
          lakiLaki: 0,
          perempuan: 0,
          kepalaKeluarga: 0,
          rerataUmur: 0.0,
          rt: 0,
          rw: 0,
          kelurahan: 1,
          kecamatan: 1,
        ));
      }

      if (CacheService.isOffline(e)) {
        final cached = await _cache.read(CacheKeys.dashboard);
        if (cached != null) {
          print('Serving dashboard from cache (${cached.cachedAt})');
          return CachedResult.fromCache(
            Dashboard.fromJson(cached.data as Map<String, dynamic>),
            cached.cachedAt,
          );
        }
      }

      // For other errors, return null to show error message
      return const CachedResult.fresh(null);
    }
  }
}
