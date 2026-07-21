package routes

import (
	"Apps-I_Desa_Backend/controllers"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/repositories"
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

func SetupImportRoutes(app *fiber.App) {
	familyCardRepo := repositories.NewFamilyCardRepository()
	villagerRepo := repositories.NewVillagerRepository()
	importService := services.NewImportService(familyCardRepo, villagerRepo)
	importTemplateService := services.NewImportTemplateService()
	importController := controllers.NewImportController(importService, importTemplateService)

	api := app.Group("/api/import")
	api.Use(middleware.JWTAuth())

	api.Get("/template", importController.DownloadTemplate)
	api.Post("/", importController.UploadImport)
}
