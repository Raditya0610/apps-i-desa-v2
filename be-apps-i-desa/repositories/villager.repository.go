package repositories

import (
	"time"

	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type VillagerRepository struct {
	DB *gorm.DB
}

func NewVillagerRepository() *VillagerRepository {
	return &VillagerRepository{
		DB: config.DB,
	}
}

func (r *VillagerRepository) BeginTransaction() *gorm.DB {
	return r.DB.Begin()
}

func (r *VillagerRepository) FindVillagerByNIK(nik *string) (*models.Villager, error) {
	var villager models.Villager
	err := r.DB.Where("nik = ?", nik).First(&villager).Error
	if err != nil {
		return nil, err
	}
	return &villager, nil
}

func (r *VillagerRepository) CreateVillagerWithTx(tx *gorm.DB, villager *models.Villager) error {
	return tx.Create(villager).Error
}

func (r *VillagerRepository) GetVillagersByFamilyCardNIK(
	familyCardNIK *string,
) ([]*dtos.GetFamilyMember, error) {
	var villagers []*models.Villager
	err := r.DB.Where("family_card_id = ?", familyCardNIK).Find(&villagers).Error
	if err != nil {
		return nil, err
	}

	var familyMembers []*dtos.GetFamilyMember
	for _, villager := range villagers {
		age := calculateAge(villager.TanggalLahir)
		familyMember := &dtos.GetFamilyMember{
			NIK:            villager.NIK,
			Name:           villager.NamaLengkap,
			StatusHubungan: villager.StatusHubungan,
			Age:            age,
			JenisKelamin:   villager.JenisKelamin,
			Pendidikan:     villager.Pendidikan,
			Pekerjaan:      villager.Pekerjaan,
		}
		familyMembers = append(familyMembers, familyMember)
	}

	return familyMembers, nil
}

func (r *VillagerRepository) GetVillagersByFamilyCardNIKs(niks []string) ([]*models.Villager, error) {
	var villagers []*models.Villager
	err := r.DB.Where("family_card_id IN ?", niks).Find(&villagers).Error
	if err != nil {
		return nil, err
	}
	return villagers, nil
}

func (r *VillagerRepository) DeleteVillagersByFamilyCardNIK(tx *gorm.DB, familyCardNIK string) error {
	return tx.Where("family_card_id = ?", familyCardNIK).Delete(&models.Villager{}).Error
}

func (r *VillagerRepository) UpdateVillagerWithTx(tx *gorm.DB, villager *models.Villager) error {
	return tx.Save(villager).Error
}

func (r *VillagerRepository) DeleteVillagerWithTx(tx *gorm.DB, nik *string) error {
	return tx.Delete(&models.Villager{}, "nik = ?", *nik).Error
}

func (r *VillagerRepository) CountAllVillagerByVillageID(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Villager{}).Where("village_id = ?", villageID).Count(&count).Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

// Gender is stored in two shapes: the villager form submits "L"/"P", while older
// rows hold "Laki-laki"/"Perempuan". Both are matched, case-insensitively, so a
// count never silently misses rows — the previous exact match on "Laki-laki"
// matched nothing at all, which reported every resident as female.
var (
	lakiLakiValues  = []string{"l", "laki-laki"}
	perempuanValues = []string{"p", "perempuan"}
)

func (r *VillagerRepository) CountAllLakiLakiVillager(villageID *uuid.UUID) (int64, error) {
	return r.countByGender(villageID, lakiLakiValues)
}

func (r *VillagerRepository) CountAllPerempuanVillager(villageID *uuid.UUID) (int64, error) {
	return r.countByGender(villageID, perempuanValues)
}

func (r *VillagerRepository) countByGender(villageID *uuid.UUID, values []string) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Villager{}).
		Where("village_id = ? AND LOWER(TRIM(jenis_kelamin)) IN ?", villageID, values).
		Count(&count).
		Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *VillagerRepository) GetAverageAge(villageID *uuid.UUID) (float32, error) {
	var averageAge float32
	err := r.DB.Model(&models.Villager{}).
		Where("village_id = ?", villageID).
		Select("AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, tanggal_lahir)))").
		Scan(&averageAge).Error
	if err != nil {
		return 0, err
	}
	return averageAge, nil
}

func (r *VillagerRepository) CountAllKepalaKeluarga(villageID *uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Villager{}).
		Where("village_id = ? AND status_hubungan = ?", villageID, "Kepala Keluarga").
		Count(&count).Error
	if err != nil {
		return 0, err
	}
	return count, nil
}

// CountByPendidikan returns the number of villagers per distinct Pendidikan
// value for the given village. Values are whatever is actually stored — the
// caller normalizes/reorders for display.
func (r *VillagerRepository) CountByPendidikan(villageID *uuid.UUID) ([]dtos.LabeledCount, error) {
	var results []dtos.LabeledCount
	err := r.DB.Model(&models.Villager{}).
		Select("pendidikan AS label, COUNT(*) AS total").
		Where("village_id = ?", villageID).
		Group("pendidikan").
		Scan(&results).Error
	if err != nil {
		return nil, err
	}
	return results, nil
}

// CountByPekerjaan returns the number of villagers per distinct Pekerjaan
// value for the given village, largest group first. Pekerjaan is free text
// (no dropdown in the manual form), so unlike Pendidikan there is no fixed
// category list to order by.
func (r *VillagerRepository) CountByPekerjaan(villageID *uuid.UUID) ([]dtos.LabeledCount, error) {
	var results []dtos.LabeledCount
	err := r.DB.Model(&models.Villager{}).
		Select("pekerjaan AS label, COUNT(*) AS total").
		Where("village_id = ?", villageID).
		Group("pekerjaan").
		Order("total DESC").
		Scan(&results).Error
	if err != nil {
		return nil, err
	}
	return results, nil
}

// GetExistingNIKs returns which of the given NIKs already exist, so bulk
// import can detect duplicates with one query instead of one per row.
func (r *VillagerRepository) GetExistingNIKs(niks []string) ([]string, error) {
	if len(niks) == 0 {
		return nil, nil
	}
	var existing []string
	err := r.DB.Model(&models.Villager{}).
		Where("nik IN ?", niks).
		Pluck("nik", &existing).Error
	if err != nil {
		return nil, err
	}
	return existing, nil
}

func calculateAge(birthDate time.Time) int {
	now := time.Now()
	age := now.Year() - birthDate.Year()

	// Adjust if birthday hasn't occurred this year
	if now.YearDay() < birthDate.YearDay() {
		age--
	}

	return age
}
