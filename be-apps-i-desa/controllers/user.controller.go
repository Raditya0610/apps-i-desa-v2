package controllers

import (
	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/services"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

type UserController struct {
	userService *services.UserService
	validate    *validator.Validate
}

func NewUserController(userService *services.UserService) *UserController {
	return &UserController{
		userService: userService,
		validate:    validator.New(),
	}
}

func (c *UserController) Register(ctx *fiber.Ctx) error {
	var request dtos.RegisterRequest

	// Parse request body
	if err := ctx.BodyParser(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid request body",
			"error":   err.Error(),
		})
	}

	// Validate request data
	if err := c.validate.Struct(&request); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Validation failed",
			"error":   err.Error(),
		})
	}

	// Process registration
	response, err := c.userService.Register(&request)
	if err != nil {
		if err.Error() == "username already registered" {
			return ctx.Status(fiber.StatusConflict).JSON(fiber.Map{
				"message": "Username already registered",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to find existing user" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to find existing user",
				"error":   err.Error(),
			})
		} else if err.Error() == "error hashing password" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error hashing password",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to create user" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to create user",
				"error":   err.Error(),
			})
		} else if err.Error() == "failed to commit transaction" {
			return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Failed to commit transaction",
				"error":   err.Error(),
			})
		} else if err.Error() == "village not found" {
			return ctx.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "Village not found",
				"error":   err.Error(),
			})
		}
		return ctx.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal Server Error",
			"error":   err.Error(),
		})
	}

	return ctx.Status(fiber.StatusCreated).JSON(response)
}

func (c *UserController) ChangePassword(ctx *fiber.Ctx) error {
	var req dtos.ChangePasswordRequest
	if err := ctx.BodyParser(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Invalid request body"})
	}
	if err := c.validate.Struct(&req); err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(fiber.Map{"message": "Validation failed", "error": err.Error()})
	}

	// Identify the acting user by username, set from the JWT claims. Tokens issued
	// before username was added to the claims won't have it — those users must log
	// in again to get a token that carries it.
	username, ok := ctx.Locals("username").(string)
	if !ok || username == "" {
		return ctx.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Sesi tidak lengkap, silakan masuk kembali",
		})
	}

	resp, err := c.userService.ChangePassword(username, &req)
	if err != nil {
		status := fiber.StatusInternalServerError
		if err.Error() == "user not found" {
			status = fiber.StatusNotFound
		} else if err.Error() == "old password is incorrect" {
			status = fiber.StatusUnauthorized
		}
		return ctx.Status(status).JSON(fiber.Map{"message": err.Error()})
	}
	return ctx.JSON(resp)
}
