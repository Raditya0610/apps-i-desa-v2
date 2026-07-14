/// One entry in the dashboard's activity feed. Written by the backend whenever
/// village data is created, updated, or deleted.
class ActivityLog {
  final String action; // create | update | delete
  final String entityType; // family_card | villager
  final String entityLabel; // person's name, or NIK when no name is available
  final String username;
  final DateTime createdAt;

  ActivityLog({
    required this.action,
    required this.entityType,
    required this.entityLabel,
    required this.username,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      action: json['action'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityLabel: json['entity_label'] as String? ?? '',
      username: json['username'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Feed headline, e.g. "Penduduk Baru".
  String get title {
    final isFamilyCard = entityType == 'family_card';
    switch (action) {
      case 'create':
        return isFamilyCard ? 'Kartu Keluarga Baru' : 'Penduduk Baru';
      case 'update':
        return isFamilyCard ? 'Update Kartu Keluarga' : 'Update Penduduk';
      case 'delete':
        return isFamilyCard ? 'Kartu Keluarga Dihapus' : 'Penduduk Dihapus';
      default:
        return 'Perubahan Data';
    }
  }

  /// Feed subtitle, e.g. "Budi Santoso ditambahkan oleh admin."
  String get description {
    final verb = switch (action) {
      'create' => 'ditambahkan',
      'update' => 'diperbarui',
      'delete' => 'dihapus',
      _ => 'diubah',
    };
    final actor = username.isEmpty ? '' : ' oleh $username';
    return '$entityLabel $verb$actor.';
  }
}
