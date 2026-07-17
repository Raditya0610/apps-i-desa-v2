package routes

import (
	"Apps-I_Desa_Backend/controllers"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/repositories"
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

func SetupUserRoutes(app *fiber.App) {
	villageRepo := repositories.NewVillageRepository()
	userRepo := repositories.NewUserRepository()
	userService := services.NewUserService(userRepo, villageRepo)
	userController := controllers.NewUserController(userService)

	userRoutes := app.Group("/api/users")
	// Registration stays self-service, but behind a shared code (X-Admin-Token).
	// It cannot require a session — it is how a village's first account is made —
	// and it was previously open to the whole internet.
	// Rate-limited first, so the shared code itself cannot be brute-forced.
	userRoutes.Post("/register", middleware.AuthRateLimiter(), middleware.AdminToken(), userController.Register)
	userRoutes.Put("/change-password", middleware.JWTAuth(), userController.ChangePassword)
}
