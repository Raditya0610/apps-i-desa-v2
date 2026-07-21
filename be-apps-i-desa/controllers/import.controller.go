package controllers

import (
	"fmt"

	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

type ImportController struct {
	importService         *services.ImportService
	importTemplateService *services.ImportTemplateService
}

func NewImportController(
	importService *services.ImportService,
	importTemplateService *services.ImportTemplateService,
) *ImportController {
	return &ImportController{
		importService:         importService,
		importTemplateService: importTemplateService,
	}
}

// DownloadTemplate generates the import workbook fresh on every request, so
// enum dropdowns always reflect the current option lists in dtos/import.dto.go.
func (c *ImportController) DownloadTemplate(ctx *fiber.Ctx) error {
	buf, err := c.importTemplateService.GenerateTemplate()
	if err != nil {
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Gagal membuat template",
			"error":   err.Error(),
		})
	}

	ctx.Set(fiber.HeaderContentType, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	ctx.Set(fiber.HeaderContentDisposition, `attachment; filename="template_import_data_penduduk.xlsx"`)
	return ctx.Send(buf.Bytes())
}

// UploadImport parses and inserts the uploaded workbook. It always responds
// 200 with a per-row report as long as the file itself is readable — a mixed
// outcome (some rows inserted, some skipped/failed) is not an HTTP error.
func (c *ImportController) UploadImport(ctx *fiber.Ctx) error {
	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "File tidak ditemukan",
			"error":   "Sertakan file pada field \"file\"",
		})
	}

	file, err := fileHeader.Open()
	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Gagal membuka file",
			"error":   err.Error(),
		})
	}
	defer file.Close()

	response, err := c.importService.ProcessImport(file, ctx)
	if err != nil {
		if err.Error() == "village ID is required" || err.Error() == "village ID is not valid" {
			return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Village ID tidak valid",
				"error":   "Check your token",
			})
		}
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Gagal memproses file",
			"error":   err.Error(),
		})
	}

	label := fmt.Sprintf(
		"Import Data: %d KK & %d penduduk ditambahkan (%d KK & %d penduduk dilewati, %d KK & %d penduduk gagal)",
		response.Summary.FamilyCardsInserted, response.Summary.VillagersInserted,
		response.Summary.FamilyCardsSkipped, response.Summary.VillagersSkipped,
		response.Summary.FamilyCardsFailed, response.Summary.VillagersFailed,
	)
	services.RecordActivity(ctx, services.ActionCreate, services.EntityImport, label)

	return ctx.Status(fiber.StatusOK).JSON(response)
}
