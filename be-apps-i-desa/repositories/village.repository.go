package repositories

import (
	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type VillageRepository struct {
	DB *gorm.DB
}

func NewVillageRepository() *VillageRepository {
	return &VillageRepository{
		DB: config.DB,
	}
}

func (r *VillageRepository) BeginTransaction() *gorm.DB {
	return r.DB.Begin()
}

func (r *VillageRepository) CreateVillageWithTx(tx *gorm.DB, village *models.Village) error {
	return tx.Create(village).Error
}

func (r *VillageRepository) FindVillageByID(uuid *uuid.UUID) error {
	var village models.Village
	if err := r.DB.First(&village, "id = ?", uuid).Error; err != nil {
		return err
	}
	return nil
}

// GetVillageByID returns the village row itself (name included), unlike
// FindVillageByID above which only confirms existence. Used to show the
// logged-in account's village name on login.
func (r *VillageRepository) GetVillageByID(id uuid.UUID) (*models.Village, error) {
	var village models.Village
	if err := r.DB.Select("id", "name").First(&village, "id = ?", id).Error; err != nil {
		return nil, err
	}
	return &village, nil
}

// FindAllVillages lists every village, for the registration dropdown.
// Villages are inserted into the database by hand; the app never creates them.
func (r *VillageRepository) FindAllVillages() ([]models.Village, error) {
	var villages []models.Village
	// Select only id and name: this feeds an unauthenticated endpoint, so it must
	// not pull the association-heavy Village row.
	if err := r.DB.Model(&models.Village{}).
		Select("id", "name").
		Order("name ASC").
		Find(&villages).Error; err != nil {
		return nil, err
	}
	return villages, nil
}

func (r *VillageRepository) FindVillageByName(name string) *models.Village {
	var village models.Village
	if err := r.DB.First(&village, "name = ?", name).Error; err != nil {
		return nil
	}
	return &village
}
