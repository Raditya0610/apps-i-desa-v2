import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  CookieJar? _cookieJar;

  // In-memory token for Flutter Web — browsers block cookies on cross-origin
  // requests (Netlify → Railway), so we fall back to Authorization: Bearer.
  static String? _authToken;
  static void setAuthToken(String? token) => _authToken = token;

  /// Called when an authenticated request comes back 401 — i.e. the JWT expired
  /// or is no longer valid. Wired by the app to clear the session and send the
  /// user to the login screen. Left null in tests / before wiring.
  static void Function()? onSessionExpired;

  // Auth endpoints legitimately return 401 (wrong password) or 401/503 (bad
  // registration code) without the session being expired, so they must not
  // trigger auto-logout.
  static bool _isAuthPath(String path) =>
      path.contains('/auth/login') ||
      path.contains('/auth/logout') ||
      path.contains('/users/register');

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConstants.defaultHeaders,
      validateStatus: (status) {
        // Accept all status codes to handle errors manually
        return status != null && status < 500;
      },
    ));

    // CookieManager tidak support web
    if (!kIsWeb) {
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // Inject Bearer token on every request (required for web cross-origin)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
    ));

    // Session watchdog: a 401 on an authenticated endpoint means the JWT expired
    // (1h TTL) or was revoked. Trigger auto-logout so the user is not stranded on
    // an authenticated screen whose every request silently fails.
    // validateStatus accepts <500, so a 401 arrives via onResponse, not onError.
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode == 401 &&
            !_isAuthPath(response.requestOptions.path)) {
          onSessionExpired?.call();
        }
        return handler.next(response);
      },
    ));

    // Add logging interceptor for debugging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[REQUEST] ${options.method} ${options.uri}');
        print('[REQUEST HEADERS] ${options.headers}');
        if (options.data != null) {
          print('[REQUEST BODY] ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('[RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
        print('[RESPONSE DATA] ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('[ERROR] ${error.requestOptions.uri}');
        print('[ERROR MESSAGE] ${error.message}');
        if (error.response != null) {
          print('[ERROR RESPONSE] ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
  CookieJar? get cookieJar => _cookieJar;

  // Clear cookies (for logout)
  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }

  // Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Extract error message from a response map, checking both lowercase and
  // capitalized keys (BE villager controller returns "Message"/"Error").
  static String getResponseError(Map<String, dynamic> data, {String fallback = 'Terjadi kesalahan'}) {
    return data['message'] ?? data['Message'] ?? data['error'] ?? data['Error'] ?? fallback;
  }

  // Handle API errors
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        if (error.response!.data is Map) {
          final data = error.response!.data as Map<String, dynamic>;
          return getResponseError(data);
        }
        return error.response!.data.toString();
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi timeout. Periksa koneksi internet Anda.';
        case DioExceptionType.badResponse:
          return 'Server error. Silakan coba lagi nanti.';
        case DioExceptionType.cancel:
          return 'Permintaan dibatalkan.';
        default:
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      }
    }
    return error.toString();
  }
}
