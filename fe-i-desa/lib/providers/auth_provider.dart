import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? username;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,  // Start with loading=true so router waits for auth check
    this.username,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? username,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await _authService.isLoggedIn();
    final username = await _authService.getUsername();
    state = state.copyWith(
      isAuthenticated: isLoggedIn,
      username: username,
      isLoading: false,
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    // isLoading intentionally NOT set here — loading is handled locally
    // in the login screen to avoid the router redirecting to /splash.
    state = state.copyWith(error: null);

    final result = await _authService.login(username, password);

    if (!result['success']) {
      state = state.copyWith(
        isAuthenticated: false,
        error: result['message'],
      );
    }
    // On success: caller must invoke finalizeLogin() after showing animation.

    return result;
  }

  /// Called by the login screen after the success animation completes.
  void finalizeLogin(String username) {
    state = state.copyWith(isAuthenticated: true, username: username);
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String villageId,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.register(username, password, villageId);

    state = state.copyWith(isLoading: false);

    return result;
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = AuthState(isAuthenticated: false, isLoading: false);
  }
}
