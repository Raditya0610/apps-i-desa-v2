package models

import "github.com/google/uuid"

type User struct {
	Username  string    `gorm:"primaryKey"`
	Password  string    `gorm:"not null"`
	VillageID uuid.UUID `gorm:"type:uuid;not null"`

	// SessionID marks this account's one active login session. Every login
	// overwrites it with a fresh UUID and embeds that value in the issued
	// JWT; JWTAuth middleware rejects any token whose embedded session_id no
	// longer matches this column. That's what forces a previously logged-in
	// device out the moment the account logs in elsewhere, rather than
	// letting both tokens stay valid until they naturally expire.
	SessionID uuid.UUID `gorm:"type:uuid"`

	// Belongs to Village
	Village Village `gorm:"foreignKey:VillageID"`
}
