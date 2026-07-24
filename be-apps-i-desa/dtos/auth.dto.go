package dtos

type LoginRequest struct {
	Username string `json:"username" validate:"required"`
	Password string `json:"password" validate:"required"`
}

type LoginResponse struct {
	Token   string `json:"token"`
	Message string `json:"message"`
	// Display-only, for the dashboard greeting — not used for any
	// authorization decision (the JWT's own "village" claim is what every
	// endpoint actually checks).
	VillageID   string `json:"village_id,omitempty"`
	VillageName string `json:"village_name,omitempty"`
}
