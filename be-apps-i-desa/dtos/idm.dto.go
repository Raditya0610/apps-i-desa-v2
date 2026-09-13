package dtos

// IDMScoreResponse is the Indeks Desa 2024 score breakdown for a village.
// Scores are integer points on the official Permendesa PDTT No. 9/2024 scale
// (6 dimensions summing to 635); Percentage = TotalScore/635*100.
type IDMScoreResponse struct {
	Year               int             `json:"year"`
	TotalScore         int             `json:"total_score"`
	Percentage         float64         `json:"percentage"`
	Status             string          `json:"status"`
	LayananDasarScore  int             `json:"layanan_dasar_score"`
	SosialScore        int             `json:"sosial_score"`
	EkonomiScore       int             `json:"ekonomi_score"`
	LingkunganScore    int             `json:"lingkungan_score"`
	AksesibilitasScore int             `json:"aksesibilitas_score"`
	TataKelolaScore    int             `json:"tata_kelola_score"`
	SubDimensionScores map[string]int  `json:"sub_dimension_scores"`
	DataCompleteness   map[string]bool `json:"data_completeness"`
}
