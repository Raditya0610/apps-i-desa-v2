package routes

import (
	"Apps-I_Desa_Backend/controllers"
	"Apps-I_Desa_Backend/repositories"
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

func SetupVillageRoutes(app *fiber.App) {
	villageRepo := repositories.NewVillageRepository()
	villageService := services.NewVillageService(villageRepo)
	villageController := controllers.NewVillageController(villageService)

	api := app.Group("/api/villages")

	// Unauthenticated on purpose: the registration screen reads this before the
	// user has an account. Returns only id and name.
	api.Get("/", villageController.GetAllVillages)

	// POST is deliberately absent. It had no auth, so anyone could create a
	// village. Villages are inserted into the database by hand;
	// VillageController.CreateVillage is kept for that path to be restored behind
	// an admin check if it is ever needed.
}
