package services

import (
	"errors"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"github.com/google/uuid"
)

// Actions and entity types recorded in the activity log. Constants rather than
// literals so the reader and the writers cannot drift apart.
const (
	ActionCreate = "create"
	ActionUpdate = "update"
	ActionDelete = "delete"

	EntityFamilyCard = "family_card"
	EntityVillager   = "villager"
)

// activityFeedLimit is how many entries the dashboard shows.
const activityFeedLimit = 10

// RecordActivity writes an audit entry for a mutation that has already succeeded.
//
// Deliberately returns nothing. The user's write is already committed, so a
// failure to log it must not turn a successful operation into an error — the
// audit trail is not worth failing a family-card insert over. Failures are logged
// to the server instead.
func RecordActivity(ctx *fiber.Ctx, action, entityType, entityLabel string) {
	villageIDStr, ok := ctx.Locals("village").(string)
	if !ok || villageIDStr == "" {
		log.Warn("Activity not recorded: no village in context")
		return
	}

	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Warnf("Activity not recorded: invalid village ID %q", villageIDStr)
		return
	}

	// Absent on tokens issued before "username" was added to the JWT claims.
	username, _ := ctx.Locals("username").(string)

	entry := &models.ActivityLog{
		VillageID:   villageID,
		Username:    username,
		Action:      action,
		EntityType:  entityType,
		EntityLabel: entityLabel,
	}

	if err := repositories.NewActivityLogRepository().Create(entry); err != nil {
		log.Errorf("Failed to record activity (%s %s): %v", action, entityType, err)
	}
}

type ActivityLogService struct {
	activityLogRepo *repositories.ActivityLogRepository
}

func NewActivityLogService(activityLogRepo *repositories.ActivityLogRepository) *ActivityLogService {
	return &ActivityLogService{activityLogRepo: activityLogRepo}
}

// GetRecent returns the newest activity for the caller's village.
func (s *ActivityLogService) GetRecent(ctx *fiber.Ctx) (*dtos.ActivityLogResponse, error) {
	villageIDStr, ok := ctx.Locals("village").(string)
	if !ok || villageIDStr == "" {
		return nil, errors.New("village ID not found")
	}

	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		return nil, errors.New("invalid village ID")
	}

	logs, err := s.activityLogRepo.FindRecentByVillage(villageID, activityFeedLimit)
	if err != nil {
		log.Error("Error fetching activity log:", err)
		return nil, errors.New("failed to fetch activity log")
	}

	items := make([]dtos.ActivityLogItem, 0, len(logs))
	for _, l := range logs {
		items = append(items, dtos.ActivityLogItem{
			Action:      l.Action,
			EntityType:  l.EntityType,
			EntityLabel: l.EntityLabel,
			Username:    l.Username,
			CreatedAt:   l.CreatedAt,
		})
	}

	return &dtos.ActivityLogResponse{Activities: items}, nil
}
