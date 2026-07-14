package controllers

import (
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

type ActivityLogController struct {
	activityLogService *services.ActivityLogService
}

func NewActivityLogController(activityLogService *services.ActivityLogService) *ActivityLogController {
	return &ActivityLogController{activityLogService: activityLogService}
}

// GetRecentActivities backs the dashboard's activity feed.
func (c *ActivityLogController) GetRecentActivities(ctx *fiber.Ctx) error {
	response, err := c.activityLogService.GetRecent(ctx)
	if err != nil {
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch activities",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusOK).JSON(response)
}
