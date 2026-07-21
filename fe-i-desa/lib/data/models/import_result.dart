/// Outcome of one row from either sheet of an uploaded import workbook.
class ImportRowResult {
  final String sheet; // "Kartu Keluarga" | "Anggota Keluarga"
  final int row; // 1-based Excel row number (header = 1)
  final String identifier; // NIK or Nomor KK, whichever applies
  final String status; // inserted | skipped_duplicate | failed
  final String reason; // Indonesian; set for skipped/failed only

  ImportRowResult({
    required this.sheet,
    required this.row,
    required this.identifier,
    required this.status,
    required this.reason,
  });

  factory ImportRowResult.fromJson(Map<String, dynamic> json) {
    return ImportRowResult(
      sheet: json['sheet'] as String? ?? '',
      row: json['row'] as int? ?? 0,
      identifier: json['identifier'] as String? ?? '',
      status: json['status'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  bool get isInserted => status == 'inserted';
  bool get isSkipped => status == 'skipped_duplicate';
  bool get isFailed => status == 'failed';
}

/// Aggregate counts across both sheets, split by entity type.
class ImportSummary {
  final int familyCardsTotal;
  final int familyCardsInserted;
  final int familyCardsSkipped;
  final int familyCardsFailed;
  final int villagersTotal;
  final int villagersInserted;
  final int villagersSkipped;
  final int villagersFailed;

  ImportSummary({
    required this.familyCardsTotal,
    required this.familyCardsInserted,
    required this.familyCardsSkipped,
    required this.familyCardsFailed,
    required this.villagersTotal,
    required this.villagersInserted,
    required this.villagersSkipped,
    required this.villagersFailed,
  });

  factory ImportSummary.fromJson(Map<String, dynamic> json) {
    return ImportSummary(
      familyCardsTotal: json['family_cards_total'] as int? ?? 0,
      familyCardsInserted: json['family_cards_inserted'] as int? ?? 0,
      familyCardsSkipped: json['family_cards_skipped'] as int? ?? 0,
      familyCardsFailed: json['family_cards_failed'] as int? ?? 0,
      villagersTotal: json['villagers_total'] as int? ?? 0,
      villagersInserted: json['villagers_inserted'] as int? ?? 0,
      villagersSkipped: json['villagers_skipped'] as int? ?? 0,
      villagersFailed: json['villagers_failed'] as int? ?? 0,
    );
  }

  int get totalRows => familyCardsTotal + villagersTotal;
  int get totalInserted => familyCardsInserted + villagersInserted;
  int get totalSkipped => familyCardsSkipped + villagersSkipped;
  int get totalFailed => familyCardsFailed + villagersFailed;
}

/// Full response body of POST /api/import.
class ImportSummaryResponse {
  final ImportSummary summary;
  final List<ImportRowResult> results;

  ImportSummaryResponse({required this.summary, required this.results});

  factory ImportSummaryResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List? ?? [];
    return ImportSummaryResponse(
      summary: ImportSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      results: rawResults
          .map((e) => ImportRowResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
