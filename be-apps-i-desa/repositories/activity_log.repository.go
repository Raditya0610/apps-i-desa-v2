package repositories

import (
	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ActivityLogRepository struct {
	DB *gorm.DB
}

func NewActivityLogRepository() *ActivityLogRepository {
	return &ActivityLogRepository{
		DB: config.DB,
	}
}

func (r *ActivityLogRepository) Create(log *models.ActivityLog) error {
	return r.DB.Create(log).Error
}

// FindRecentByVillage returns the newest entries for one village.
func (r *ActivityLogRepository) FindRecentByVillage(
	villageID uuid.UUID,
	limit int,
) ([]models.ActivityLog, error) {
	var logs []models.ActivityLog
	err := r.DB.
		Where("village_id = ?", villageID).
		Order("created_at DESC").
		Limit(limit).
		Find(&logs).Error
	if err != nil {
		return nil, err
	}
	return logs, nil
}
