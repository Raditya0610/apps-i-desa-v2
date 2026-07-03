class IdmScoreModel {
  final int year;
  final double idmScore;
  final double iksScore;
  final double ikeScore;
  final double iklScore;
  final String status;
  final Map<String, double> subDimensionScores;
  final Map<String, bool> dataCompleteness;

  const IdmScoreModel({
    required this.year,
    required this.idmScore,
    required this.iksScore,
    required this.ikeScore,
    required this.iklScore,
    required this.status,
    required this.subDimensionScores,
    required this.dataCompleteness,
  });

  factory IdmScoreModel.fromJson(Map<String, dynamic> json) {
    return IdmScoreModel(
      year: (json['year'] as num?)?.toInt() ?? 0,
      idmScore: (json['idm_score'] as num?)?.toDouble() ?? 0.0,
      iksScore: (json['iks_score'] as num?)?.toDouble() ?? 0.0,
      ikeScore: (json['ike_score'] as num?)?.toDouble() ?? 0.0,
      iklScore: (json['ikl_score'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '-',
      subDimensionScores: (json['sub_dimension_scores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
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
