package dtos

import "github.com/google/uuid"

type RegisterRequest struct {
	Username string `json:"username"   validate:"required"`
	// min=6 matches ChangePasswordRequest.NewPassword below — registration was
	// the one path that let an account get created with an arbitrarily short
	// password (even a single character) in the first place.
	Password  string    `json:"password"   validate:"required,min=6"`
	VillageID uuid.UUID `json:"village_id" validate:"required,uuid"`
}

type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" validate:"required"`
	NewPassword string `json:"new_password" validate:"required,min=6"`
}
