package dtos

import "github.com/google/uuid"

type AddVillageRequest struct {
	Name string `json:"name" validate:"required"`
}

type CreateVillageResponse struct {
	ID      uuid.UUID `json:"id"`
	Name    string    `json:"name"`
	Message string    `json:"message"`
}

// VillageOption is one entry in the registration dropdown. Deliberately just id
// and name — this is served without authentication.
type VillageOption struct {
	ID   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

type ListVillagesResponse struct {
	Villages []VillageOption `json:"villages"`
}
