package dtos

// LabeledCount is one bucket of a group-by-and-count breakdown (e.g. one
// education level or one occupation) — shared shape since Pendidikan and
// Pekerjaan summaries are structurally identical.
type LabeledCount struct {
	Label string `json:"label"`
	Total int64  `json:"total"`
}

type GetDashboardResponse struct {
	TotalKeluarga       int32   `json:"totalKeluarga"`
	TotalPenduduk       int32   `json:"totalPenduduk"`
	RerataKeluarga      float32 `json:"rerataKeluarga"`
	TotalLakiLaki       int32   `json:"lakiLaki"`
	TotalPerempuan      int32   `json:"perempuan"`
	TotalKepalaKeluarga int32   `json:"kepalaKeluarga"`
	RerataUmur          float32 `json:"rerataUmur"`
	TotalRT             int32   `json:"rt"`
	TotalRW             int32   `json:"rw"`
	TotalKelurahan      int32   `json:"kelurahan"`
	TotalKecamatan      int32   `json:"kecamatan"`

	// PendidikanBreakdown is ordered by education level (lowest to highest,
	// matching ImportPendidikanOptions), not by count — a jumbled order would
	// defeat the point of a progression chart. PekerjaanBreakdown is freeform
	// text, so it's ordered by count descending with a capped "Lainnya" bucket.
	PendidikanBreakdown []LabeledCount `json:"pendidikanBreakdown"`
	PekerjaanBreakdown  []LabeledCount `json:"pekerjaanBreakdown"`
}
