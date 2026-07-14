package models

import (
	"time"

	"github.com/google/uuid"
)

// ActivityLog records a mutation to village data, so the dashboard can show what
// actually happened instead of a hardcoded list.
//
// Append-only: rows are written after a successful mutation and never updated.
type ActivityLog struct {
	ID        uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	VillageID uuid.UUID `gorm:"type:uuid;not null;index"`

	// Who. Empty for sessions issued before username was added to the JWT claims.
	Username string `gorm:"size:100"`

	// What: "create" | "update" | "delete".
	Action string `gorm:"size:20;not null"`

	// Which kind of thing: "family_card" | "villager".
	EntityType string `gorm:"size:50;not null"`

	// Human-readable subject, e.g. the person's name. Shown in the activity feed.
	EntityLabel string `gorm:"size:200"`

	// Indexed with VillageID: the feed is always "latest N for one village".
	CreatedAt time.Time `gorm:"index"`

	Village Village `gorm:"foreignKey:VillageID"`
}
