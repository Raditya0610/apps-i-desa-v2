import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/activity_log.dart';
import '../data/models/cached_result.dart';
import '../data/repositories/activity_log_repository.dart';

final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  return ActivityLogRepository();
});

/// Recent activity for the dashboard feed.
final recentActivitiesProvider =
    FutureProvider<CachedResult<List<ActivityLog>>>((ref) async {
  return ref.read(activityLogRepositoryProvider).getRecentActivities();
});
