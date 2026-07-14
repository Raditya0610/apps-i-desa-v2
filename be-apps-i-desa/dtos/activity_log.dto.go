package dtos

import "time"

type ActivityLogItem struct {
	Action      string    `json:"action"`       // create | update | delete
	EntityType  string    `json:"entity_type"`  // family_card | villager
	EntityLabel string    `json:"entity_label"` // e.g. the person's name
	Username    string    `json:"username"`
	CreatedAt   time.Time `json:"created_at"`
}

type ActivityLogResponse struct {
	Activities []ActivityLogItem `json:"activities"`
}
