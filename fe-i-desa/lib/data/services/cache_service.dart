import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A cached payload plus the moment it was fetched from the API.
class CacheEntry {
  final dynamic data;
  final DateTime? cachedAt;

  const CacheEntry(this.data, this.cachedAt);
}

/// Read-through cache for API responses, so the app keeps working during the
/// frequent internet outages at the desa office.
///
/// Backed by SharedPreferences because it is the only storage that works on both
/// targets we ship: Windows desktop (file) and Flutter web (localStorage). A
/// sqlite-backed store would be faster but has no web implementation. One village's
/// data is small enough that storing whole responses as JSON is fine.
///
/// This caches reads only. Writes made while offline still fail — see the offline
/// write-queue follow-up.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _prefix = 'idesa_cache.';
  static const String _timestampSuffix = '.cached_at';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Stores a decoded JSON response ([Map] or [List]) under [key].
  Future<void> write(String key, Object json) async {
    try {
      final storage = await _storage;
      await storage.setString('$_prefix$key', jsonEncode(json));
      await storage.setString(
        '$_prefix$key$_timestampSuffix',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // A cache write must never break an otherwise successful fetch.
      print('[CACHE] Failed to write "$key": $e');
    }
  }

  /// Returns the last stored response for [key], or null if nothing is cached.
  Future<CacheEntry?> read(String key) async {
    try {
      final storage = await _storage;
      final raw = storage.getString('$_prefix$key');
      if (raw == null) return null;

      final timestamp = storage.getString('$_prefix$key$_timestampSuffix');
      return CacheEntry(
        jsonDecode(raw),
        timestamp == null ? null : DateTime.tryParse(timestamp),
      );
    } catch (e) {
      print('[CACHE] Failed to read "$key": $e');
      return null;
    }
  }

  /// Drops every cached response. Called on logout — the cache holds village data
  /// and the next user on this machine may belong to a different village.
  Future<void> clear() async {
    try {
      final storage = await _storage;
      // Materialised before removing: getKeys() is a live view, and mutating it
      // mid-iteration throws ConcurrentModificationError.
      final keys =
          storage.getKeys().where((k) => k.startsWith(_prefix)).toList();
      for (final key in keys) {
        await storage.remove(key);
      }
    } catch (e) {
      print('[CACHE] Failed to clear: $e');
    }
  }

  /// Whether [error] means "we could not reach the server", as opposed to the
  /// server answering with a rejection.
  ///
  /// Only these fall back to cache. A 401/403/404 is a real answer from a
  /// reachable backend, and serving stale data over it would hide the actual
  /// problem. A 5xx counts as unreachable: Railway or Aiven is down, and the
  /// last good copy beats an error screen.
  static bool isOffline(Object error) {
    if (error is! DioException) return false;

    // Listed rather than switched on: an exhaustive switch breaks the build
    // whenever Dio adds an enum value, and the safe default for an unrecognised
    // failure is "not offline" (surface the error) rather than "serve stale data".
    const unreachable = {
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      // Only 5xx lands here — ApiService.validateStatus lets 4xx return normally.
      DioExceptionType.badResponse,
    };
    if (unreachable.contains(error.type)) return true;

    // Dio reports a dead DNS/socket as `unknown` wrapping a SocketException.
    return error.type == DioExceptionType.unknown && error.error is Exception;
  }
}

/// Cache keys, kept in one place so a typo cannot silently split a cache entry
/// into two.
class CacheKeys {
  static const String dashboard = 'dashboard';
  static const String familyCards = 'family_cards';

  static String familyCardDetail(String nik) => 'family_card_detail.$nik';
}
