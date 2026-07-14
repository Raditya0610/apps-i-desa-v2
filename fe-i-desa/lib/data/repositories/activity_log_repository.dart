import '../models/activity_log.dart';
import '../models/cached_result.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/mock_api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class ActivityLogRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();
  final CacheService _cache = CacheService();

  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  Future<CachedResult<List<ActivityLog>>> getRecentActivities() async {
    try {
      final response = await _api.get(ApiConstants.activities);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final activities = data['activities'] as List? ?? [];
        if (!AppConfig.useMockApi) {
          await _cache.write(CacheKeys.activities, activities);
        }
        return CachedResult.fresh(_parse(activities));
      }
      return const CachedResult.fresh([]);
    } catch (e) {
      print('Error fetching activities: ${ApiService.getErrorMessage(e)}');

      if (CacheService.isOffline(e)) {
        final cached = await _cache.read(CacheKeys.activities);
        if (cached != null) {
          return CachedResult.fromCache(
            _parse(cached.data as List),
            cached.cachedAt,
          );
        }
      }

      return const CachedResult.fresh([]);
    }
  }

  List<ActivityLog> _parse(List json) => json
      .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
      .toList();
}
