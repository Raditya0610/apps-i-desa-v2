package services

import (
	"errors"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FamilyCardService struct {
	familyCardRepo *repositories.FamilyCardRepository
	villagerRepo   *repositories.VillagerRepository
}

func NewFamilyCardService(
	familyCardRepo *repositories.FamilyCardRepository,
	villagerRepo *repositories.VillagerRepository,
) *FamilyCardService {
	return &FamilyCardService{
		familyCardRepo: familyCardRepo,
		villagerRepo:   villagerRepo,
	}
}

func (s *FamilyCardService) CreateFamilyCard(
	request *dtos.AddFamilyCardRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.familyCardRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID is required")
	}
	villageID, err := uuid.Parse(villageIDStr)
	// Check if the village ID is valid
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("village ID is not valid")
	}

	// Check if the NIK already exists
	existingFamilyCard, err := s.familyCardRepo.GetFamilyCardByNIK(&request.NIK)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		log.Error("Database Error", err)
		return nil, errors.New("failed to find existing family card")
	}
	if existingFamilyCard != nil {
		log.Error("Family card with this NIK already exists")
		return nil, errors.New("family card with this NIK already exists")
	}

	familyCard := &models.FamilyCard{
		NIK:           request.NIK,
		Alamat:        request.Address,
		RT:            request.RT,
		RW:            request.RW,
		Kelurahan:     request.Kelurahan,
		Kecamatan:     request.Kecamatan,
		KabupatenKota: request.KabupatenKota,
		Provinsi:      request.Provinsi,
		KodePos:       request.KodePos,
		VillageID:     villageID,
	}

	if err := s.familyCardRepo.CreateWithTx(tx, familyCard); err != nil {
		log.Error("Error creating family card:", err)
		return nil, errors.New("failed to create family card")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Family card created successfully",
	}, nil
}

func (s *FamilyCardService) GetFamilyCardByNIK(nik string) (*dtos.GetAllFamilyMember, error) {
	response, err := s.familyCardRepo.GetNIKAndAddressByNIK(nik)
	if err != nil {
		log.Error("Error getting family card by NIK:", err)
		return nil, errors.New("failed to get family card by NIK")
	}

	villagers, err := s.villagerRepo.GetVillagersByFamilyCardNIK(&nik)
	if err != nil {
		log.Error("Error getting villagers by family card ID:", err)
		return nil, errors.New("failed to get villagers by family card ID")
	}

	if response == nil {
		log.Error("Family card not found for NIK:", nik)
		return nil, errors.New("family card not found")
	}

	// Convert []*dtos.GetFamilyMember to []dtos.GetFamilyMember
	var familyMembers []dtos.GetFamilyMember
	for _, villager := range villagers {
		if villager != nil {
			familyMembers = append(familyMembers, *villager)
		}
	}

	return &dtos.GetAllFamilyMember{
		NIK:           nik,
		Address:       response.Address,
		FamilyMembers: familyMembers,
	}, nil
}

func (s *FamilyCardService) DeleteFamilyCard(nik string) error {
	tx := s.familyCardRepo.BeginTransaction()
	defer tx.Rollback()

	existing, err := s.familyCardRepo.GetFamilyCardByNIK(&nik)
	if err != nil {
		return errors.New("family card not found")
	}
	if existing == nil {
		return errors.New("family card not found")
	}

	// Bulk delete all villagers belonging to this family card
	if err := s.villagerRepo.DeleteVillagersByFamilyCardNIK(tx, nik); err != nil {
		return errors.New("failed to delete villagers for family card")
	}

	if err := s.familyCardRepo.DeleteFamilyCardByNIK(tx, nik); err != nil {
		return errors.New("failed to delete family card")
	}
	if err := tx.Commit().Error; err != nil {
		return errors.New("failed to commit transaction")
	}
	return nil
}

func (s *FamilyCardService) GetAllFamilyCardsByVillageID(
	ctx *fiber.Ctx,
) (*dtos.GetAllFamilyCardsResponse, error) {
	villageIDStr := ctx.Locals("village").(string)
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID is required")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("village ID is not valid")
	}

	familyCards, err := s.familyCardRepo.GetAllFamilyCardsByVillageID(&villageID)
	if err != nil {
		log.Error("Error getting all family cards:", err)
		return nil, errors.New("failed to get all family cards")
	}
	if len(familyCards) == 0 {
		return &dtos.GetAllFamilyCardsResponse{}, nil
	}

	// Collect all NIKs and fetch villagers in one query
	niks := make([]string, len(familyCards))
	for i, card := range familyCards {
		niks[i] = card.NIK
	}
	allVillagers, err := s.villagerRepo.GetVillagersByFamilyCardNIKs(niks)
	if err != nil {
		log.Error("Error getting villagers:", err)
		return nil, errors.New("failed to get villagers")
	}

	// Group by family_card_id
	villagersByNIK := make(map[string][]*models.Villager, len(familyCards))
	for _, v := range allVillagers {
		villagersByNIK[v.FamilyCardID] = append(villagersByNIK[v.FamilyCardID], v)
	}

	var response dtos.GetAllFamilyCardsResponse
	for _, card := range familyCards {
		members := villagersByNIK[card.NIK]
		var kepalaKeluarga string
		for _, v := range members {
			if v.StatusHubungan == "Kepala Keluarga" {
				kepalaKeluarga = v.NamaLengkap
				break
			}
		}
		response.FamilyCards = append(response.FamilyCards, dtos.GetFamilyCardResponse{
			NIK:          card.NIK,
			Name:         &kepalaKeluarga,
			TotalMembers: len(members),
		})
	}

	return &response, nil
}
