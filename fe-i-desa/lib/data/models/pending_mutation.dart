/// A single queued write (create/update/delete) that failed because the
/// device was offline, to be replayed once connectivity returns.
///
/// See [WriteQueueService] (`write_queue_service.dart`) for how these are
/// persisted and flushed.
enum MutationDomain {
  familyCard,
  villager;

  String get storageValue => name;

  static MutationDomain fromStorage(String value) =>
      MutationDomain.values.firstWhere((d) => d.storageValue == value);
}

enum MutationOp {
  create,
  update,
  delete;

  String get storageValue => name;

  static MutationOp fromStorage(String value) =>
      MutationOp.values.firstWhere((o) => o.storageValue == value);
}

class PendingMutation {
  /// Local bookkeeping id only — never sent to the backend. Family
  /// card/villager idempotency comes from the NIK primary key, not this id.
  final String id;
  final MutationDomain domain;
  final MutationOp op;

  /// The NIK this mutation is about — used for display and for patching the
  /// read cache so the UI reflects the change immediately.
  final String entityKey;

  final String method; // 'POST' | 'PUT' | 'DELETE'
  final String path;
  final Map<String, dynamic>? body;

  /// The village this mutation was queued under — a flush only ever replays
  /// entries belonging to the currently authenticated village, so a
  /// different village logging in on a shared machine can never trigger (or
  /// silently lose) another village's pending writes.
  final String villageId;

  final DateTime queuedAt;
  final int retryCount;

  /// Set once a replay attempt fails for a reason other than "unreachable"
  /// (e.g. a real validation rejection). A failed entry is not retried
  /// automatically again — it waits for the operator to retry or dismiss it.
  final String? lastError;

  const PendingMutation({
    required this.id,
    required this.domain,
    required this.op,
    required this.entityKey,
    required this.method,
    required this.path,
    required this.body,
    required this.villageId,
    required this.queuedAt,
    this.retryCount = 0,
    this.lastError,
  });

  bool get isFailed => lastError != null;

  PendingMutation copyWith({int? retryCount, String? lastError}) {
    return PendingMutation(
      id: id,
      domain: domain,
      op: op,
      entityKey: entityKey,
      method: method,
      path: path,
      body: body,
      villageId: villageId,
      queuedAt: queuedAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain.storageValue,
        'op': op.storageValue,
        'entityKey': entityKey,
        'method': method,
        'path': path,
        'body': body,
        'villageId': villageId,
        'queuedAt': queuedAt.toIso8601String(),
        'retryCount': retryCount,
        'lastError': lastError,
      };

  factory PendingMutation.fromJson(Map<String, dynamic> json) {
    return PendingMutation(
      id: json['id'] as String,
      domain: MutationDomain.fromStorage(json['domain'] as String),
      op: MutationOp.fromStorage(json['op'] as String),
      entityKey: json['entityKey'] as String,
      method: json['method'] as String,
      path: json['path'] as String,
      body: (json['body'] as Map?)?.cast<String, dynamic>(),
      villageId: json['villageId'] as String,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }
}
