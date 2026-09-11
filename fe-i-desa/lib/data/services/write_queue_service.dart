import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pending_mutation.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'cache_service.dart';

/// Persisted queue of writes (create/update/delete) that failed while the
/// device was offline, replayed once connectivity returns.
///
/// Backed by SharedPreferences for the same reason [CacheService] is — it is
/// the only storage that works on both Windows desktop and Flutter web.
///
/// A flush only ever replays entries belonging to the currently
/// authenticated village (see [flush]) — on a shared desa-office computer, a
/// different village logging in must never trigger, and must never silently
/// drop, another village's still-pending writes.
class WriteQueueService {
  static final WriteQueueService _instance = WriteQueueService._internal();
  factory WriteQueueService() => _instance;
  WriteQueueService._internal();

  static const String _storageKey = 'idesa_queue.pending_mutations';

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  bool _flushing = false;

  /// Notified after every enqueue/flush/retry/dismiss so the UI can react
  /// without polling.
  final List<void Function()> _listeners = [];
  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  Future<List<PendingMutation>> _loadAll() async {
    final storage = await _storage;
    final raw = storage.getString(_storageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => PendingMutation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[WRITE QUEUE] Failed to decode queue, resetting: $e');
      return [];
    }
  }

  Future<void> _saveAll(List<PendingMutation> entries) async {
    final storage = await _storage;
    await storage.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
    _notify();
  }

  Future<void> enqueue(PendingMutation mutation) async {
    final all = await _loadAll();
    all.add(mutation);
    await _saveAll(all);
  }

  /// Every queued entry, regardless of which village queued it. Used only by
  /// the sync panel's "all pending" bookkeeping — day-to-day UI should use
  /// [pendingFor] instead, scoped to the active village.
  Future<List<PendingMutation>> all() => _loadAll();

  Future<List<PendingMutation>> pendingFor(String villageId) async {
    final all = await _loadAll();
    return all.where((m) => m.villageId == villageId).toList()
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
  }

  Future<void> dismiss(String id) async {
    final all = await _loadAll();
    all.removeWhere((m) => m.id == id);
    await _saveAll(all);
  }

  /// Clears a failed entry's error so the next [flush] retries it.
  Future<void> retry(String id) async {
    final all = await _loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) return;
    all[index] = all[index].copyWith(lastError: null);
    await _saveAll(all);
    await flush();
  }

  /// Replays every pending entry for the currently authenticated village, in
  /// the order they were queued. Stops at the first entry that is still
  /// unreachable (network down again, server 5xx, or the session just
  /// expired) rather than marking it failed — the rest of the queue is left
  /// untouched for the next attempt.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final villageId = await _authService.getVillageId();
      if (villageId == null || villageId.isEmpty) return;

      final all = await _loadAll();
      final mine = all.where((m) => m.villageId == villageId && !m.isFailed).toList()
        ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));

      for (final entry in mine) {
        final result = await _replayOne(entry);
        switch (result.outcome) {
          case _ReplayOutcome.applied:
            await dismiss(entry.id);
            break;
          case _ReplayOutcome.stillUnreachable:
            return; // Leave the rest queued; try again on the next trigger.
          case _ReplayOutcome.rejected:
            await _markFailed(entry.id, result.error!);
            break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  Future<void> _markFailed(String id, String error) async {
    final all = await _loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) return;
    all[index] = all[index].copyWith(
      retryCount: all[index].retryCount + 1,
      lastError: error,
    );
    await _saveAll(all);
  }

  Future<_ReplayResult> _replayOne(PendingMutation entry) async {
    try {
      final response = await switch (entry.method) {
        'POST' => _apiService.post(entry.path, data: entry.body),
        'PUT' => _apiService.put(entry.path, data: entry.body),
        'DELETE' => _apiService.delete(entry.path),
        _ => throw StateError('Unknown method ${entry.method}'),
      };

      final status = response.statusCode ?? 0;

      if (status == 200 || status == 201) {
        return const _ReplayResult(_ReplayOutcome.applied);
      }
      // Create replayed after a partial flush that actually landed server-side
      // last time — 409 means the NIK already exists, i.e. this exact write is
      // already in effect.
      if (entry.op == MutationOp.create && status == 409) {
        return const _ReplayResult(_ReplayOutcome.applied);
      }
      // Update/delete replayed against a record that a previous, only
      // partially-confirmed flush already changed/removed.
      if ((entry.op == MutationOp.update || entry.op == MutationOp.delete) &&
          status == 404) {
        return const _ReplayResult(_ReplayOutcome.applied);
      }
      // The JWT expired while offline — ApiService's own 401 watchdog is
      // already tearing the session down. Don't mark this a permanent
      // rejection; it'll be retried once the operator logs back in.
      if (status == 401) {
        return const _ReplayResult(_ReplayOutcome.stillUnreachable);
      }

      return _ReplayResult(
        _ReplayOutcome.rejected,
        error: 'HTTP $status: ${_extractMessage(response.data)}',
      );
    } catch (e) {
      if (CacheService.isOffline(e)) {
        return const _ReplayResult(_ReplayOutcome.stillUnreachable);
      }
      return _ReplayResult(_ReplayOutcome.rejected, error: ApiService.getErrorMessage(e));
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return ApiService.getResponseError(data);
    }
    return data?.toString() ?? 'Terjadi kesalahan';
  }
}

enum _ReplayOutcome { applied, stillUnreachable, rejected }

class _ReplayResult {
  final _ReplayOutcome outcome;
  final String? error;
  const _ReplayResult(this.outcome, {this.error});
}
