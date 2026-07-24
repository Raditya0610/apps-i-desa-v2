package controllers

import (
	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/services"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

type VillagerController struct {
	villagerService *services.VillagerService
	validate        *validator.Validate
}

func NewVillagerController(villagerService *services.VillagerService) *VillagerController {
	return &VillagerController{
		villagerService: villagerService,
		validate:        validator.New(),
	}
}

func (c *VillagerController) CreateVillager(ctx *fiber.Ctx) error {
	var request dtos.AddVillagerRequest

	if err := ctx.BodyParser(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "Invalid request body",
			"Error":   err.Error(),
		})
	}

	if err := c.validate.Struct(request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "Validation failed",
			"Error":   err.Error(),
		})
	}

	response, err := c.villagerService.CreateVillager(&request, ctx)
	if err != nil {
		if err.Error() == "invalid village ID format" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Invalid village ID format",
				"Error":   err.Error(),
			})
		} else if err.Error() == "village ID is required" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Village ID is required",
				"Error":   err.Error(),
			})
		} else if err.Error() == "invalid date format, expected YYYY-MM-DD" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Invalid date format",
				"Error":   err.Error(),
			})
		} else if err.Error() == "villager with the same NIK already exists" {
			return ctx.Status(fiber.StatusConflict).JSON(fiber.Map{
				"Message": "Villager with the same NIK already exists",
				"Error":   err.Error(),
			})
		} else if err.Error() == "family card not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"Message": "Family card not found",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to check family card" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to check family card",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to check existing villager" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to check existing villager",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to create villager" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to create villager",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to commit transaction",
				"Error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"Message": "Failed to create villager",
			"Error":   err.Error(),
		})
	}

	// After the write is committed, so a failed audit cannot roll back real data.
	services.RecordActivity(ctx, services.ActionCreate, services.EntityVillager, request.NamaLengkap)

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *VillagerController) GetVillager(ctx *fiber.Ctx) error {
	nik := ctx.Params("nik")
	if nik == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "NIK is required",
		})
	}

	response, err := c.villagerService.GetVillagerByNIK(&nik, ctx)
	if err != nil {
		if err.Error() == "villager not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"Message": "Villager not found",
				"Error":   err.Error(),
			})
		} else if err.Error() == "village ID is required" || err.Error() == "invalid village ID format" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Invalid village ID",
				"Error":   "Check your token",
			})
		} else if err.Error() == "failed to get villager by NIK" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to get villager by NIK",
				"Error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"Message": "Internal Server Error",
			"Error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusOK).JSON(response)
}

func (c *VillagerController) UpdateVillager(ctx *fiber.Ctx) error {
	var request dtos.UpdateVillagerRequest
	nik := ctx.Params("nik")
	if nik == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "NIK is required",
		})
	}
	// Validate NIK format
	if len(nik) != 16 {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "NIK must be 16 characters long",
		})
	}
	// Check if NIK contains only digits
	for _, char := range nik {
		if char < '0' || char > '9' {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "NIK must contain only digits",
			})
		}
	}

	if err := ctx.BodyParser(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "Invalid request body",
			"Error":   err.Error(),
		})
	}
	if err := c.validate.Struct(request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "Validation failed",
			"Error":   err.Error(),
		})
	}

	response, err := c.villagerService.UpdateVillager(&nik, &request, ctx)
	if err != nil {
		if err.Error() == "villager not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"Message": "Villager not found",
				"Error":   err.Error(),
			})
		} else if err.Error() == "village ID is required" || err.Error() == "invalid village ID format" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Invalid village ID",
				"Error":   "Check your token",
			})
		} else if err.Error() == "failed to find villager" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Failed to find villager",
				"Error":   err.Error(),
			})
		} else if err.Error() == "invalid date format, expected YYYY-MM-DD" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Invalid date format, expected YYYY-MM-DD",
				"Error":   err.Error(),
			})
		} else if err.Error() == "villager with the same NIK already exists" {
			return ctx.Status(fiber.StatusConflict).JSON(fiber.Map{
				"Message": "Villager with the same NIK already exists",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to check existing villager" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to check existing villager",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to update villager" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to find villager",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to commit transaction",
				"Error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"Message": "Internal Server Error",
			"Error":   err.Error(),
		})
	}

	// Prefer the new name; fall back to the NIK when the update did not touch it.
	label := nik
	if request.NamaLengkap != nil && *request.NamaLengkap != "" {
		label = *request.NamaLengkap
	}
	services.RecordActivity(ctx, services.ActionUpdate, services.EntityVillager, label)

	return ctx.Status(fiber.StatusOK).JSON(response)
}

func (c *VillagerController) DeleteVillager(ctx *fiber.Ctx) error {
	nik := ctx.Params("nik")
	if nik == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "NIK is required",
		})
	}
	// Validate NIK format
	if len(nik) != 16 {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"Message": "NIK must be 16 characters long",
		})
	}
	// Check if NIK contains only digits
	for _, char := range nik {
		if char < '0' || char > '9' {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "NIK must contain only digits",
			})
		}
	}

	response, err := c.villagerService.DeleteVillager(&nik, ctx)
	if err != nil {
		if err.Error() == "villager not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"Message": "Villager not found",
				"Error":   err.Error(),
			})
		} else if err.Error() == "village ID is required" || err.Error() == "invalid village ID format" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Invalid village ID",
				"Error":   "Check your token",
			})
		} else if err.Error() == "failed to find villager" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"Message": "Failed to find villager",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to commit transaction",
				"Error":   err.Error(),
			})
		} else if err.Error() == "failed to delete villager" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"Message": "Failed to delete villager",
				"Error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"Message": "Internal Server Error",
			"Error":   err.Error(),
		})
	}

	services.RecordActivity(ctx, services.ActionDelete, services.EntityVillager, nik)

	return ctx.Status(fiber.StatusOK).JSON(response)
}
