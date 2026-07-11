import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dashboard.dart';
import '../data/repositories/dashboard_repository.dart';

// Dashboard Repository Provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Dashboard Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.read(dashboardRepositoryProvider));
});

// Dashboard State
class DashboardState {
  final Dashboard? dashboard;
  final bool isLoading;
  final String? error;

  /// Set when the server was unreachable and [dashboard] is a cached copy.
  final bool isFromCache;
  final DateTime? cachedAt;

  DashboardState({
    this.dashboard,
    this.isLoading = false,
    this.error,
    this.isFromCache = false,
    this.cachedAt,
  });

  DashboardState copyWith({
    Dashboard? dashboard,
    bool? isLoading,
    String? error,
    bool? isFromCache,
    DateTime? cachedAt,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFromCache: isFromCache ?? this.isFromCache,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

// Dashboard Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getDashboard();

      if (result.data != null) {
        // Built directly rather than via copyWith so a fresh load clears the
        // stale-cache flags left by a previous offline load.
        state = DashboardState(
          dashboard: result.data,
          isLoading: false,
          isFromCache: result.isFromCache,
          cachedAt: result.cachedAt,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Gagal memuat data dashboard',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: $e',
      );
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
