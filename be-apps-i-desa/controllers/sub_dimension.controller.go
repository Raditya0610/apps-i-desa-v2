package controllers

import (
	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/services"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

type SubDimensionController struct {
	subDimensionService *services.SubDimensionService
	validate            *validator.Validate
}

func NewSubDimensionController(
	subDimensionService *services.SubDimensionService,
) *SubDimensionController {
	return &SubDimensionController{
		subDimensionService: subDimensionService,
		validate:            validator.New(),
	}
}

func (c *SubDimensionController) CreateSubDimensionPendidikan(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionPendidikanRequest

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

	response, err := c.subDimensionService.CreateSubDimensionPendidikan(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension pendidikan" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension pendidikan",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionKesehatan(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionKesehatanRequest

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

	response, err := c.subDimensionService.CreateSubDimensionKesehatan(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension kesehatan" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension kesehatan",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionUtilitasDasar(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionUtilitasDasarRequest

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

	response, err := c.subDimensionService.CreateSubDimensionUtilitasDasar(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension utilitas dasar" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension utilitas dasar",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionAktivitas(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionAktivitasRequest

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

	response, err := c.subDimensionService.CreateSubDimensionAktivitas(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension aktivitas" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension aktivitas",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionFasilitasMasyarakat(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionFasilitasMasyarakatRequest

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

	response, err := c.subDimensionService.CreateSubDimensionFasilitasMasyarakat(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension fasilitas masyarakat" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension fasilitas masyarakat",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionProduksiDesa(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionProduksiDesaRequest

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

	response, err := c.subDimensionService.CreateSubDimensionProduksiDesa(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension produksi desa" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension produksi desa",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionFasilitasPendukungEkonomi(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionFasilitasPendukungEkonomiRequest

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

	response, err := c.subDimensionService.CreateSubDimensionFasilitasPendukungEkonomi(
		&request,
		ctx,
	)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension fasilitas pendukung ekonomi" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension fasilitas pendukung ekonomi",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionPengelolaanLingkungan(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionPengelolaanLingkunganRequest

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

	response, err := c.subDimensionService.CreateSubDimensionPengelolaanLingkungan(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension pengelolaan lingkungan" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension pengelolaan lingkungan",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionPenanggulanganBencana(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionPenanggulanganBencanaRequest

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

	response, err := c.subDimensionService.CreateSubDimensionPenanggulanganBencana(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension penanggulangan bencana" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension penanggulangan bencana",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionKondisiAksesJalan(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionKondisiAksesJalanRequest

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

	response, err := c.subDimensionService.CreateSubDimensionKondisiAksesJalan(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension kondisi akses jalan" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension kondisi akses jalan",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionKemudahanAkses(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionKemudahanAksesRequest

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

	response, err := c.subDimensionService.CreateSubDimensionKemudahanAkses(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension kemudahan akses" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension kemudahan akses",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionKelembagaanPelayananDesa(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionKelembagaanPelayananDesaRequest

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

	response, err := c.subDimensionService.CreateSubDimensionKelembagaanPelayananDesa(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension kelembagaan pelayanan desa" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension kelembagaan pelayanan desa",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *SubDimensionController) CreateSubDimensionTataKelolaKeuanganDesa(ctx *fiber.Ctx) error {
	var request dtos.AddSubDimensionTataKelolaKeuanganDesaRequest

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

	response, err := c.subDimensionService.CreateSubDimensionTataKelolaKeuanganDesa(&request, ctx)
	if err != nil {
		if err.Error() == "village ID not found" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID not found",
				"error":   "Check your token",
			})
		} else if err.Error() == "invalid village ID" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Invalid village ID",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create sub dimension tata kelola keuangan desa" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Invalid sub-dimension type",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create sub-dimension tata kelola keuangan desa",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

// â”€â”€ shared helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func deleteSubDimHandler(svc func(string) error) fiber.Handler {
	return func(ctx *fiber.Ctx) error {
		if err := svc(ctx.Params("id")); err != nil {
			status := fiber.StatusInternalServerError
			if err.Error() == "record not found" || err.Error() == "invalid ID" {
				status = fiber.StatusNotFound
			}
			return ctx.Status(status).JSON(fiber.Map{"message": err.Error()})
		}
		return ctx.JSON(fiber.Map{"message": "deleted successfully"})
	}
}

func updateErrResponse(ctx *fiber.Ctx, err error) error {
	status := fiber.StatusInternalServerError
	if err.Error() == "record not found" || err.Error() == "invalid ID" {
		status = fiber.StatusNotFound
	}
	return ctx.Status(status).JSON(fiber.Map{"message": err.Error()})
}

// â”€â”€ GET handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func (c *SubDimensionController) GetPendidikan(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetPendidikan(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetKesehatan(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetKesehatan(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetUtilitasDasar(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetUtilitasDasar(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetAktivitas(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetAktivitas(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetFasilitasMasyarakat(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetFasilitasMasyarakat(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetProduksiDesa(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetProduksiDesa(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetFasilitasPendukungEkonomi(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetFasilitasPendukungEkonomi(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetPengelolaanLingkungan(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetPengelolaanLingkungan(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetPenanggulanganBencana(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetPenanggulanganBencana(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetKondisiAksesJalan(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetKondisiAksesJalan(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetKemudahanAkses(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetKemudahanAkses(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetKelembagaanPelayananDesa(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetKelembagaanPelayananDesa(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}
func (c *SubDimensionController) GetTataKelolaKeuanganDesa(ctx *fiber.Ctx) error {
	data, err := c.subDimensionService.GetTataKelolaKeuanganDesa(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(data)
}

// â”€â”€ DELETE handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func (c *SubDimensionController) DeletePendidikan(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeletePendidikan)(ctx)
}
func (c *SubDimensionController) DeleteKesehatan(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteKesehatan)(ctx)
}
func (c *SubDimensionController) DeleteUtilitasDasar(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteUtilitasDasar)(ctx)
}
func (c *SubDimensionController) DeleteAktivitas(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteAktivitas)(ctx)
}
func (c *SubDimensionController) DeleteFasilitasMasyarakat(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteFasilitasMasyarakat)(ctx)
}
func (c *SubDimensionController) DeleteProduksiDesa(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteProduksiDesa)(ctx)
}
func (c *SubDimensionController) DeleteFasilitasPendukungEkonomi(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteFasilitasPendukungEkonomi)(ctx)
}
func (c *SubDimensionController) DeletePengelolaanLingkungan(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeletePengelolaanLingkungan)(ctx)
}
func (c *SubDimensionController) DeletePenanggulanganBencana(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeletePenanggulanganBencana)(ctx)
}
func (c *SubDimensionController) DeleteKondisiAksesJalan(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteKondisiAksesJalan)(ctx)
}
func (c *SubDimensionController) DeleteKemudahanAkses(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteKemudahanAkses)(ctx)
}
func (c *SubDimensionController) DeleteKelembagaanPelayananDesa(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteKelembagaanPelayananDesa)(ctx)
}
func (c *SubDimensionController) DeleteTataKelolaKeuanganDesa(ctx *fiber.Ctx) error {
	return deleteSubDimHandler(c.subDimensionService.DeleteTataKelolaKeuanganDesa)(ctx)
}

// â”€â”€ PUT handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func (c *SubDimensionController) UpdatePendidikan(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionPendidikanRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdatePendidikan(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateKesehatan(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionKesehatanRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateKesehatan(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateUtilitasDasar(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionUtilitasDasarRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateUtilitasDasar(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateAktivitas(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionAktivitasRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateAktivitas(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateFasilitasMasyarakat(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionFasilitasMasyarakatRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateFasilitasMasyarakat(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateProduksiDesa(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionProduksiDesaRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateProduksiDesa(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateFasilitasPendukungEkonomi(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionFasilitasPendukungEkonomiRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateFasilitasPendukungEkonomi(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdatePengelolaanLingkungan(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionPengelolaanLingkunganRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdatePengelolaanLingkungan(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdatePenanggulanganBencana(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionPenanggulanganBencanaRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdatePenanggulanganBencana(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateKondisiAksesJalan(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionKondisiAksesJalanRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateKondisiAksesJalan(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateKemudahanAkses(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionKemudahanAksesRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateKemudahanAkses(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateKelembagaanPelayananDesa(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionKelembagaanPelayananDesaRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateKelembagaanPelayananDesa(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}
func (c *SubDimensionController) UpdateTataKelolaKeuanganDesa(ctx *fiber.Ctx) error {
	var req dtos.AddSubDimensionTataKelolaKeuanganDesaRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.subDimensionService.UpdateTataKelolaKeuanganDesa(ctx.Params("id"), &req); err != nil {
		return updateErrResponse(ctx, err)
	}
	return ctx.JSON(fiber.Map{"message": "updated successfully"})
}

