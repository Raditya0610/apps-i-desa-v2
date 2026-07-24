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
	villageRepo := repositories.NewVillageRepository()
	authService := services.NewAuthService(authRepo, villageRepo)
	authController := controllers.NewAuthController(authService)

	// Auth routes
	authRoutes := app.Group("/api/auth")
	// Rate-limited: this is the password brute-force surface.
	authRoutes.Post("/login", middleware.AuthRateLimiter(), authController.Login)
	// JWTAuth so Logout knows whose session to invalidate. Safe even though the
	// token is about to be discarded client-side — the frontend calls this
	// before clearing its local token, so the Authorization header is still
	// present and still valid at this point.
	authRoutes.Post("/logout", middleware.JWTAuth(), authController.Logout)
}
