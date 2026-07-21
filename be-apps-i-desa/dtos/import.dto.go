package dtos

// Enum option lists shared by the import template (dropdown source) and the
// bulk-import validator. Defined once here so the two can never drift — the
// same slice populates the Excel dropdown and would back a future oneof
// validator tag, rather than duplicating the list in two places.
//
// Must stay identical to fe-i-desa/lib/presentation/widgets/family_cards/
// villager_form_dialog.dart's dropdown option lists (the manual "Tambah
// Penduduk" form). If the two diverge, a value the template's dropdown allows
// could still look wrong when edited later through the manual form.
var (
	ImportJenisKelaminOptions = []string{"Laki-laki", "Perempuan"}

	ImportAgamaOptions = []string{
		"Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu",
	}

	ImportPendidikanOptions = []string{
		"Tidak/Belum Sekolah", "Belum Tamat SD/Sederajat", "Tamat SD/Sederajat",
		"SLTP/Sederajat", "SLTA/Sederajat", "Diploma I/II",
		"Akademi/Diploma III/Sarjana Muda", "Diploma IV/Strata I", "Strata II", "Strata III",
	}

	ImportStatusPerkawinanOptions = []string{
		"Belum Kawin", "Kawin", "Cerai Hidup", "Cerai Mati",
	}

	ImportStatusHubunganOptions = []string{
		"Kepala Keluarga", "Istri", "Anak", "Menantu", "Cucu",
		"Orang Tua", "Mertua", "Famili Lain", "Pembantu", "Lainnya",
	}

	ImportKewarganegaraanOptions = []string{"WNI", "WNA"}
)

// ── Import result reporting ─────────────────────────────────────────────────

// Row outcome statuses. A string type (not iota) because these are the exact
// values serialized to the frontend and compared in tests.
const (
	ImportStatusInserted         = "inserted"
	ImportStatusSkippedDuplicate = "skipped_duplicate"
	ImportStatusFailed           = "failed"
)

// ImportRowResult reports what happened to one data row from either sheet.
type ImportRowResult struct {
	Sheet      string `json:"sheet"`                // "Kartu Keluarga" | "Anggota Keluarga"
	Row        int    `json:"row"`                  // 1-based Excel row number (header = 1)
	Identifier string `json:"identifier"`            // NIK or Nomor KK, whichever applies
	Status     string `json:"status"`                // inserted | skipped_duplicate | failed
	Reason     string `json:"reason,omitempty"`      // Indonesian; set for skipped/failed only
}

// ImportSummary aggregates counts across both sheets, split by entity type so
// the results screen can show "45 KK, 120 penduduk" rather than one combined
// number that hides which sheet needs attention.
type ImportSummary struct {
	FamilyCardsTotal    int `json:"family_cards_total"`
	FamilyCardsInserted int `json:"family_cards_inserted"`
	FamilyCardsSkipped  int `json:"family_cards_skipped"`
	FamilyCardsFailed   int `json:"family_cards_failed"`

	VillagersTotal    int `json:"villagers_total"`
	VillagersInserted int `json:"villagers_inserted"`
	VillagersSkipped  int `json:"villagers_skipped"`
	VillagersFailed   int `json:"villagers_failed"`
}

// ImportSummaryResponse is the full response body for POST /api/import.
// Returned with 200 even when some/all rows failed — a mixed outcome is not
// an HTTP error, it is the normal result of a bulk operation. Only
// structural problems (missing sheet, corrupt file, no village in the
// caller's token) produce a 4xx/5xx instead of this body.
type ImportSummaryResponse struct {
	Summary ImportSummary     `json:"summary"`
	Results []ImportRowResult `json:"results"`
}
