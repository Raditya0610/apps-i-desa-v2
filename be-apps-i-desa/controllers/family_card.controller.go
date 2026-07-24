package controllers

import (
	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/services"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

type FamilyCardController struct {
	familyCardService *services.FamilyCardService
	validate          *validator.Validate
}

func NewFamilyCardController(familyCardService *services.FamilyCardService) *FamilyCardController {
	return &FamilyCardController{
		familyCardService: familyCardService,
		validate:          validator.New(),
	}
}

// AddFamilyCard handles the creation of a new family card
func (c *FamilyCardController) AddFamilyCard(ctx *fiber.Ctx) error {
	var request dtos.AddFamilyCardRequest

	// Parse the request body into the AddFamilyCardRequest struct
	if err := ctx.BodyParser(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid request body",
			"error":   err.Error(),
		})
	}

	// Validate the request data
	if err := c.validate.Struct(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Validation failed",
			"error":   err.Error(),
		})
	}

	// Call the service to create the family card
	response, err := c.familyCardService.CreateFamilyCard(&request, ctx)
	if err != nil {
		if err.Error() == "village ID is required" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID is required",
				"error":   "Check your token",
			})
		} else if err.Error() == "village ID is not valid" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID format",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to check existing family card" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to check existing family card",
				"error":   err.Error(),
			})
		} else if err.Error() == "family card with this NIK already exists" {
			return ctx.Status(fiber.StatusConflict).JSON(fiber.Map{
				"message": "Family card with this NIK already exists",
			})
		} else if err.Error() == "failed to create family card" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to create family card",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create family card",
			"error":   err.Error(),
		})
	}

	// After the write is committed, so a failed audit cannot roll back real data.
	services.RecordActivity(ctx, services.ActionCreate, services.EntityFamilyCard, request.NIK)

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

// GetFamilyCardByNIK retrieves a family card by its NIK
func (c *FamilyCardController) GetFamilyCardByNIK(ctx *fiber.Ctx) error {
	familyCardID := ctx.Params("id")
	if familyCardID == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Family card ID is required",
			"error":   "Check your request parameters",
		})
	}

	response, err := c.familyCardService.GetFamilyCardByNIK(familyCardID, ctx)
	if err != nil {
		if err.Error() == "family card not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "Family card not found",
				"error":   err.Error(),
			})
		} else if err.Error() == "village ID is required" || err.Error() == "village ID is not valid" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   "Check your token",
			})
		} else if err.Error() == "failed to get family card by NIK" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to retrieve family card",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to get villagers by family card ID" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to get villagers for family card",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to retrieve family card",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusOK).JSON(response)
}

// UpdateFamilyCard handles partial updates to an existing family card
func (c *FamilyCardController) UpdateFamilyCard(ctx *fiber.Ctx) error {
	nik := ctx.Params("id")
	if nik == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "NIK is required",
		})
	}

	var request dtos.UpdateFamilyCardRequest
	if err := ctx.BodyParser(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid request body",
			"error":   err.Error(),
		})
	}
	if err := c.validate.Struct(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Validation failed",
			"error":   err.Error(),
		})
	}

	response, err := c.familyCardService.UpdateFamilyCard(nik, &request, ctx)
	if err != nil {
		if err.Error() == "family card not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "Family card not found",
				"error":   err.Error(),
			})
		} else if err.Error() == "village ID is required" || err.Error() == "village ID is not valid" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   "Check your token",
			})
		} else if err.Error() == "failed to get family card by NIK" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to retrieve family card",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to update family card" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to update family card",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to update family card",
			"error":   err.Error(),
		})
	}

	services.RecordActivity(ctx, services.ActionUpdate, services.EntityFamilyCard, nik)

	return ctx.Status(fiber.StatusOK).JSON(response)
}

func (c *FamilyCardController) DeleteFamilyCard(ctx *fiber.Ctx) error {
	nik := ctx.Params("id")
	if nik == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "NIK is required",
		})
	}
	if err := c.familyCardService.DeleteFamilyCard(nik, ctx); err != nil {
		if err.Error() == "family card not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "Family card not found",
			})
		} else if err.Error() == "village ID is required" || err.Error() == "village ID is not valid" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   "Check your token",
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to delete family card",
			"error":   err.Error(),
		})
	}
	services.RecordActivity(ctx, services.ActionDelete, services.EntityFamilyCard, nik)

	return ctx.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Family card deleted successfully",
	})
}

func (c *FamilyCardController) GetAllFamilyCards(ctx *fiber.Ctx) error {
	response, err := c.familyCardService.GetAllFamilyCardsByVillageID(ctx)
	if err != nil {
		if err.Error() == "village ID is required" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID is required",
				"error":   "Check your token",
			})
		} else if err.Error() == "village ID is not valid" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID format",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to get all family cards" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to retrieve family cards",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to get villagers for family card" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to get villagers for family card",
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to retrieve family cards",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusOK).JSON(response)
}
