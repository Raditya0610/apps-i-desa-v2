package repositories

import (
	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FamilyCardRepository struct {
	DB *gorm.DB
}

func NewFamilyCardRepository() *FamilyCardRepository {
	return &FamilyCardRepository{
		DB: config.DB,
	}
}

func (r *FamilyCardRepository) BeginTransaction() *gorm.DB {
	return r.DB.Begin()
}

func (r *FamilyCardRepository) CreateWithTx(tx *gorm.DB, familyCard *models.FamilyCard) error {
	return tx.Create(familyCard).Error
}

func (r *FamilyCardRepository) GetAllFamilyCardsByVillageID(
	villageID *uuid.UUID,
) ([]*models.FamilyCard, error) {
	var familyCards []*models.FamilyCard
	err := r.DB.Where("village_id = ?", villageID).Find(&familyCards).Error
	if err != nil {
		return nil, err
	}
	return familyCards, nil
}

func (r *FamilyCardRepository) GetFamilyCardByNIK(nik *string) (*models.FamilyCard, error) {
	var familyCard models.FamilyCard
	err := r.DB.Where("nik = ?", nik).First(&familyCard).Error
	if err != nil {
		return nil, err
	}
	return &familyCard, nil
}

func (r *FamilyCardRepository) CountAllFamilyCardByVillageID(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.FamilyCard{}).Where("village_id = ?", villageID).Count(&count).Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *FamilyCardRepository) CountDistinctRT(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.FamilyCard{}).
		Where("village_id = ?", villageID).
		Distinct("rt").
		Count(&count).
		Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *FamilyCardRepository) CountDistinctRW(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.FamilyCard{}).
		Where("village_id = ?", villageID).
		Distinct("rw").
		Count(&count).
		Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *FamilyCardRepository) CountDistinctKelurahan(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.FamilyCard{}).
		Where("village_id = ?", villageID).
		Distinct("kelurahan").
		Count(&count).
		Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *FamilyCardRepository) CountDistinctKecamatan(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.FamilyCard{}).
		Where("village_id = ?", villageID).
		Distinct("kecamatan").
		Count(&count).
		Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *FamilyCardRepository) DeleteFamilyCardByNIK(tx *gorm.DB, nik string) error {
	return tx.Delete(&models.FamilyCard{}, "nik = ?", nik).Error
}

// GetExistingNIKs returns which of the given NIKs already exist, so bulk
// import can detect duplicates with one query instead of one per row. Not
// scoped to a village: NIK/Nomor KK is meant to be nationally unique, so a
// collision anywhere is a legitimate duplicate regardless of which village
// created it.
func (r *FamilyCardRepository) GetExistingNIKs(niks []string) ([]string, error) {
	if len(niks) == 0 {
		return nil, nil
	}
	var existing []string
	err := r.DB.Model(&models.FamilyCard{}).
		Where("nik IN ?", niks).
		Pluck("nik", &existing).Error
	if err != nil {
		return nil, err
	}
	return existing, nil
}

// GetExistingNIKsInVillage is the village-scoped counterpart to
// GetExistingNIKs. Bulk import uses this — not the unscoped version — to
// decide whether a villager row may link to an existing Nomor KK: without
// scoping, a family card that happens to already exist in a different
// village would still count as "usable", letting an import silently attach a
// new villager to another village's family.
func (r *FamilyCardRepository) GetExistingNIKsInVillage(villageID uuid.UUID, niks []string) ([]string, error) {
	if len(niks) == 0 {
		return nil, nil
	}
	var existing []string
	err := r.DB.Model(&models.FamilyCard{}).
		Where("village_id = ? AND nik IN ?", villageID, niks).
		Pluck("nik", &existing).Error
	if err != nil {
		return nil, err
	}
	return existing, nil
}
