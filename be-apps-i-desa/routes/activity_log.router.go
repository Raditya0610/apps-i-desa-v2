package routes

import (
	"Apps-I_Desa_Backend/controllers"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/repositories"
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

func SetupActivityLogRoutes(app *fiber.App) {
	activityLogRepo := repositories.NewActivityLogRepository()
	activityLogService := services.NewActivityLogService(activityLogRepo)
	activityLogController := controllers.NewActivityLogController(activityLogService)

	api := app.Group("/api/activities")
	// Scoped to the caller's village by the JWT claim; never returns another
	// village's activity.
	api.Use(middleware.JWTAuth())

	api.Get("/", activityLogController.GetRecentActivities)
}
