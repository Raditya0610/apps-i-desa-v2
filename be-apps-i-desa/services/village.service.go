package services

import (
	"errors"
	"log"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
)

type VillageService struct {
	villageRepo *repositories.VillageRepository
}

func NewVillageService(villageRepo *repositories.VillageRepository) *VillageService {
	return &VillageService{
		villageRepo: villageRepo,
	}
}

// GetAllVillages backs the registration dropdown.
func (s *VillageService) GetAllVillages() (*dtos.ListVillagesResponse, error) {
	villages, err := s.villageRepo.FindAllVillages()
	if err != nil {
		log.Println("Error listing villages:", err)
		return nil, errors.New("failed to list villages")
	}

	options := make([]dtos.VillageOption, 0, len(villages))
	for _, v := range villages {
		options = append(options, dtos.VillageOption{ID: v.ID, Name: v.Name})
	}

	return &dtos.ListVillagesResponse{Villages: options}, nil
}

func (s *VillageService) CreateVillage(
	request *dtos.AddVillageRequest,
) (*dtos.CreateVillageResponse, error) {
	tx := s.villageRepo.BeginTransaction()
	defer tx.Rollback()

	village := &models.Village{
		Name: request.Name,
	}

	if err := s.villageRepo.CreateVillageWithTx(tx, village); err != nil {
		log.Println("Error creating village:", err)
		return nil, errors.New("failed to create village")
	}

	if err := tx.Commit().Error; err != nil {
		log.Println("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	newVillage := s.villageRepo.FindVillageByName(request.Name)
	if newVillage == nil {
		return nil, errors.New("village not found after creation")
	}

	return &dtos.CreateVillageResponse{
		Message: "Village created successfully",
		ID:      newVillage.ID,
		Name:    newVillage.Name,
	}, nil
}
