package dtos

type IDMScoreResponse struct {
	Year               int                `json:"year"`
	IDMScore           float64            `json:"idm_score"`
	IKSScore           float64            `json:"iks_score"`
	IKEScore           float64            `json:"ike_score"`
	IKLScore           float64            `json:"ikl_score"`
	Status             string             `json:"status"`
	SubDimensionScores map[string]float64 `json:"sub_dimension_scores"`
	DataCompleteness   map[string]bool    `json:"data_completeness"`
}
