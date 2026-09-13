/// Indeks Desa 2024 score breakdown for a village (Permendesa PDTT No. 9/2024,
/// replaces the old IDM/IKS/IKE/IKL model). All dimension/sub-dimension scores
/// are integer points on the official 635-point scale; [percentage] is
/// [totalScore] / 635 * 100.
class IdmScoreModel {
  final int year;
  final int totalScore;
  final double percentage;
  final String status;
  final int layananDasarScore;
  final int sosialScore;
  final int ekonomiScore;
  final int lingkunganScore;
  final int aksesibilitasScore;
  final int tataKelolaScore;
  final Map<String, int> subDimensionScores;
  final Map<String, bool> dataCompleteness;

  const IdmScoreModel({
    required this.year,
    required this.totalScore,
    required this.percentage,
    required this.status,
    required this.layananDasarScore,
    required this.sosialScore,
    required this.ekonomiScore,
    required this.lingkunganScore,
    required this.aksesibilitasScore,
    required this.tataKelolaScore,
    required this.subDimensionScores,
    required this.dataCompleteness,
  });

  factory IdmScoreModel.fromJson(Map<String, dynamic> json) {
    return IdmScoreModel(
      year: (json['year'] as num?)?.toInt() ?? 0,
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '-',
      layananDasarScore: (json['layanan_dasar_score'] as num?)?.toInt() ?? 0,
      sosialScore: (json['sosial_score'] as num?)?.toInt() ?? 0,
      ekonomiScore: (json['ekonomi_score'] as num?)?.toInt() ?? 0,
      lingkunganScore: (json['lingkungan_score'] as num?)?.toInt() ?? 0,
      aksesibilitasScore: (json['aksesibilitas_score'] as num?)?.toInt() ?? 0,
      tataKelolaScore: (json['tata_kelola_score'] as num?)?.toInt() ?? 0,
      subDimensionScores: (json['sub_dimension_scores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      dataCompleteness: (json['data_completeness'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          {},
    );
  }

  int get completedCount =>
      dataCompleteness.values.where((v) => v).length;

  int get totalCount => dataCompleteness.length;
}
