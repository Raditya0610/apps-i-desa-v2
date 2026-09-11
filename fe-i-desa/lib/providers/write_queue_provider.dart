import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pending_mutation.dart';
import '../data/services/auth_service.dart';
import '../data/services/write_queue_service.dart';

/// Pending writes queued for the currently authenticated village, kept in
/// sync with [WriteQueueService]'s persisted storage.
final writeQueueProvider =
    StateNotifierProvider<WriteQueueNotifier, List<PendingMutation>>((ref) {
  return WriteQueueNotifier();
});

class WriteQueueNotifier extends StateNotifier<List<PendingMutation>> {
  final WriteQueueService _service = WriteQueueService();
  final AuthService _authService = AuthService();

  WriteQueueNotifier() : super(const []) {
    _service.addListener(_reload);
    _reload();
  }

  Future<void> _reload() async {
    final villageId = await _authService.getVillageId();
    if (villageId == null || villageId.isEmpty) {
      state = const [];
      return;
    }
    state = await _service.pendingFor(villageId);

    // Opportunistic flush on (re)load — covers login after being offline
    // while logged out: the device may have stayed online the whole time,
    // so there is no fresh connectivity-change event to trigger this instead.
    if (state.isNotEmpty) {
      unawaited(_service.flush());
    }
  }

  Future<void> flushNow() => _service.flush();

  Future<void> retry(String id) => _service.retry(id);

  Future<void> dismiss(String id) => _service.dismiss(id);

  @override
  void dispose() {
    _service.removeListener(_reload);
    super.dispose();
  }
}

/// Owns the live connectivity subscription that triggers a queue flush
/// whenever the device regains a connection. `connectivity_plus` only
/// reports interface state (WiFi/data up or down), not real reachability —
/// good enough to catch "WiFi came back on", with the sync panel's manual
/// "Sinkronkan sekarang" as the fallback for a WiFi-up-but-no-real-internet
/// captive-portal case.
///
/// Must be watched from a widget that lives for the whole app session
/// (there is no ShellRoute in this app — layout is composed per-screen via
/// AppShell, which is rebuilt on every navigation) — see `MyApp` in
/// `lib/app.dart`, the one widget that is always mounted.
final connectivitySyncProvider = Provider<void>((ref) {
  final subscription = Connectivity().onConnectivityChanged.listen((results) {
    if (!results.contains(ConnectivityResult.none)) {
      WriteQueueService().flush();
    }
  });
  ref.onDispose(subscription.cancel);
});
