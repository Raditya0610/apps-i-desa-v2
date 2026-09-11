import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';
import 'api_service.dart';
import 'cache_service.dart';
import 'mock_api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // In-memory storage for mock mode or when secure storage fails (macOS keychain issues)
  static final Map<String, String> _mockStorage = {};
  static bool _useInMemoryStorage = false;

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _villageIdKey = 'village_id';
  static const String _villageNameKey = 'village_name';
  static const String _passwordHashKey = 'password_hash';
  static const String _lastValidatedKey = 'last_validated_at';

  /// Grace period for offline token reuse (72 hours)
  static const Duration _offlineGracePeriod = Duration(hours: 72);

  // Helper methods for storage abstraction
  Future<void> _write(String key, String value) async {
    if (AppConfig.useMockApi || _useInMemoryStorage) {
      _mockStorage[key] = value;
    } else {
      try {
        await _storage.write(key: key, value: value);
      } catch (e) {
        // Fallback to in-memory storage on macOS keychain error
        print('[AUTH SERVICE] Secure storage failed, using in-memory storage: $e');
        _useInMemoryStorage = true;
        _mockStorage[key] = value;
      }
    }
  }

  Future<String?> _read(String key) async {
    if (AppConfig.useMockApi || _useInMemoryStorage) {
      return _mockStorage[key];
    } else {
      try {
        return await _storage.read(key: key);
      } catch (e) {
        // Fallback to in-memory storage on macOS keychain error
        print('[AUTH SERVICE] Secure storage failed, using in-memory storage: $e');
        _useInMemoryStorage = true;
        return _mockStorage[key];
      }
    }
  }

  Future<void> _deleteAll() async {
    if (AppConfig.useMockApi || _useInMemoryStorage) {
      _mockStorage.clear();
    } else {
      try {
        await _storage.deleteAll();
      } catch (e) {
        // Fallback to in-memory storage on macOS keychain error
        _useInMemoryStorage = true;
        _mockStorage.clear();
      }
    }

    // The offline cache holds one village's data; the next user on this shared
    // desa computer may belong to a different village.
    await CacheService().clear();
  }

  /// Clears the local session without calling the server's /logout.
  ///
  /// Used when the token has already expired: the server would just answer 401
  /// again, and routing the expiry handler back through the API could loop.
  Future<void> clearLocalSession() async {
    await _deleteAll();
    ApiService.setAuthToken(null);
    if (AppConfig.useMockApi) {
      await _mockApiService.clearAuth();
    } else {
      await _apiService.clearCookies();
    }
  }

  // Login
  //
  // On failure, the result carries an `unreachable` flag (see
  // [CacheService.isOffline]) so callers can tell a connectivity failure
  // (safe to retry offline) apart from a real rejection like bad credentials.
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _api.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;

        // Drop any cached data from a previous session before this account's
        // data is fetched. The cache keys are not scoped per village, so without
        // this a login that later goes offline could serve the previous user's
        // residents — a cross-village PII leak. Logout also clears it, but a
        // login can happen without a preceding logout (expired token, app reuse).
        await CacheService().clear();

        // Save token and username
        await _write(_tokenKey, token);
        await _write(_usernameKey, username);
        ApiService.setAuthToken(token);

        // Cache password hash for offline login
        await _cachePasswordHash(password);
        await _updateLastValidated();

        // Save village_id/village_name straight from the login response —
        // display-only (the greeting), never used for any access decision.
        final villageId = data['village_id'] as String?;
        final villageName = data['village_name'] as String?;
        if (villageId != null && villageId.isNotEmpty) {
          await _write(_villageIdKey, villageId);
        }
        if (villageName != null && villageName.isNotEmpty) {
          await _write(_villageNameKey, villageName);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'token': token,
          'villageName': villageName ?? '',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Login gagal'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'unreachable': CacheService.isOffline(e),
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      await _api.post(ApiConstants.logout);

      // Clear storage and cookies
      await _deleteAll();
      ApiService.setAuthToken(null);
      if (AppConfig.useMockApi) {
        await _mockApiService.clearAuth();
      } else {
        await _apiService.clearCookies();
      }

      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    } catch (e) {
      // Even if the API call fails, clear local data
      await _deleteAll();
      ApiService.setAuthToken(null);
      if (AppConfig.useMockApi) {
        await _mockApiService.clearAuth();
      } else {
        await _apiService.clearCookies();
      }

      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    }
  }

  // Register User
  //
  // [registrationCode] is the shared secret the developer hands to the desa
  // operator. Registration cannot require a session — it is how a village's first
  // account is created — so this code is what keeps the endpoint from being open
  // to anyone who loads the public site.
  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String villageId,
    String registrationCode,
  ) async {
    try {
      final response = await _api.post(
        ApiConstants.register,
        data: {
          'username': username,
          'password': password,
          'village_id': villageId,
        },
        options: Options(
          headers: {ApiConstants.adminTokenHeader: registrationCode},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Registrasi berhasil',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Registrasi gagal'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  // Check if user is logged in (also restores token into ApiService on app start)
  Future<bool> isLoggedIn() async {
    final token = await _read(_tokenKey);
    if (token != null && token.isNotEmpty) {
      // If offline, make sure the cached session is still within the grace
      // period before letting the user straight in.
      if (!await hasConnectivity()) {
        if (!await isTokenValidOffline()) {
          return false;
        }
      }
      ApiService.setAuthToken(token);
      return true;
    }
    return false;
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _read(_tokenKey);
  }

  // Get stored username
  Future<String?> getUsername() async {
    return await _read(_usernameKey);
  }

  // Get stored village ID
  Future<String?> getVillageId() async {
    return await _read(_villageIdKey);
  }

  // Get stored village name
  Future<String?> getVillageName() async {
    return await _read(_villageNameKey);
  }

  // Save village ID
  Future<void> saveVillageId(String villageId) async {
    await _write(_villageIdKey, villageId);
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.put(
        ApiConstants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password berhasil diubah',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal mengubah password'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  // ─── Offline Support ──────────────────────────────────────────────────────

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Hash password for secure local storage
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cache password hash for offline login (called after successful online login)
  Future<void> _cachePasswordHash(String password) async {
    final hash = _hashPassword(password);
    await _write(_passwordHashKey, hash);
  }

  /// Update last validated timestamp
  Future<void> _updateLastValidated() async {
    await _write(_lastValidatedKey, DateTime.now().toIso8601String());
  }

  /// Check if cached token is within offline grace period
  Future<bool> isTokenValidOffline() async {
    final token = await _read(_tokenKey);
    final lastValidatedStr = await _read(_lastValidatedKey);

    if (token == null || token.isEmpty || lastValidatedStr == null) {
      return false;
    }

    final lastValidated = DateTime.tryParse(lastValidatedStr);
    if (lastValidated == null) return false;

    final elapsed = DateTime.now().difference(lastValidated);
    return elapsed < _offlineGracePeriod;
  }

  /// Attempt offline login using cached credentials
  ///
  /// Returns success if:
  /// 1. Password hash matches cached hash
  /// 2. Token is within offline grace period
  Future<Map<String, dynamic>> loginOffline(
    String username,
    String password,
  ) async {
    try {
      // Check if we have cached credentials
      final storedUsername = await _read(_usernameKey);
      final storedHash = await _read(_passwordHashKey);

      if (storedUsername == null || storedHash == null) {
        return {
          'success': false,
          'message': 'Tidak ada data login tersimpan. Silakan login online terlebih dahulu.',
        };
      }

      // Verify username matches
      if (username != storedUsername) {
        return {
          'success': false,
          'message': 'Username tidak cocok dengan data tersimpan.',
        };
      }

      // Verify password hash
      final inputHash = _hashPassword(password);
      if (inputHash != storedHash) {
        return {
          'success': false,
          'message': 'Password salah.',
        };
      }

      // Check if token is within grace period
      if (!await isTokenValidOffline()) {
        return {
          'success': false,
          'message': 'Sesi telah berakhir. Silakan login online untuk memperbarui.',
        };
      }

      // Restore session from cache
      final token = await _read(_tokenKey);
      final villageName = await _read(_villageNameKey);

      ApiService.setAuthToken(token);

      return {
        'success': true,
        'message': 'Login offline berhasil',
        'token': token,
        'villageName': villageName ?? '',
        'isOffline': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal login offline: ${e.toString()}',
      };
    }
  }
}
