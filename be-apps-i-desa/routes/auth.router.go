package routes

import (
	"Apps-I_Desa_Backend/controllers"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/repositories"
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

func SetupAuthRoutes(app *fiber.App) {
	// Initialize dependencies
	authRepo := repositories.NewUserRepository()
	authService := services.NewAuthService(authRepo)
	authController := controllers.NewAuthController(authService)

	// Auth routes
	authRoutes := app.Group("/api/auth")
	// Rate-limited: this is the password brute-force surface.
	authRoutes.Post("/login", middleware.AuthRateLimiter(), authController.Login)
	authRoutes.Post("/logout", authController.Logout)
}
