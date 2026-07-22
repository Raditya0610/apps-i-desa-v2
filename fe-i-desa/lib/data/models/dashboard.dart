/// One bucket of a group-by-and-count breakdown (one education level, or one
/// occupation) — mirrors the backend's shared LabeledCount shape.
class LabeledCount {
  final String label;
  final int total;

  LabeledCount({required this.label, required this.total});

  factory LabeledCount.fromJson(Map<String, dynamic> json) {
    return LabeledCount(
      label: json['label'] as String? ?? '',
      total: json['total'] as int? ?? 0,
    );
  }
}

class Dashboard {
  final int totalKeluarga;
  final int totalPenduduk;
  final double rerataKeluarga;
  final int lakiLaki;
  final int perempuan;
  final int kepalaKeluarga;
  final double rerataUmur;
  final int rt;
  final int rw;
  final int kelurahan;
  final int kecamatan;
  final List<LabeledCount> pendidikanBreakdown;
  final List<LabeledCount> pekerjaanBreakdown;

  Dashboard({
    required this.totalKeluarga,
    required this.totalPenduduk,
    required this.rerataKeluarga,
    required this.lakiLaki,
    required this.perempuan,
    required this.kepalaKeluarga,
    required this.rerataUmur,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    required this.kecamatan,
    this.pendidikanBreakdown = const [],
    this.pekerjaanBreakdown = const [],
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalKeluarga: json['totalKeluarga'] as int? ?? 0,
      totalPenduduk: json['totalPenduduk'] as int? ?? 0,
      rerataKeluarga: (json['rerataKeluarga'] as num?)?.toDouble() ?? 0.0,
      lakiLaki: json['lakiLaki'] as int? ?? 0,
      perempuan: json['perempuan'] as int? ?? 0,
      kepalaKeluarga: json['kepalaKeluarga'] as int? ?? 0,
      rerataUmur: (json['rerataUmur'] as num?)?.toDouble() ?? 0.0,
      rt: json['rt'] as int? ?? 0,
      rw: json['rw'] as int? ?? 0,
      kelurahan: json['kelurahan'] as int? ?? 0,
      kecamatan: json['kecamatan'] as int? ?? 0,
      pendidikanBreakdown: ((json['pendidikanBreakdown'] as List?) ?? [])
          .map((e) => LabeledCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      pekerjaanBreakdown: ((json['pekerjaanBreakdown'] as List?) ?? [])
          .map((e) => LabeledCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Gender ratio calculation
  double get genderRatioMale {
    if (totalPenduduk == 0) return 0;
    return (lakiLaki / totalPenduduk) * 100;
  }

  double get genderRatioFemale {
    if (totalPenduduk == 0) return 0;
    return (perempuan / totalPenduduk) * 100;
  }

  // Rasio Keluarga calculation (population density index)
  double get rasioKeluarga {
    if (totalKeluarga == 0) return 0;
    return totalPenduduk / totalKeluarga;
  }
}
