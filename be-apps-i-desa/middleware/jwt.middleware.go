package middleware

import (
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

func JWTAuth() fiber.Handler {
	return func(c *fiber.Ctx) error {
		var tokenStr string

		// Prefer Authorization: Bearer <token> header (works for cross-origin web)
		authHeader := c.Get("Authorization")
		if strings.HasPrefix(authHeader, "Bearer ") {
			tokenStr = strings.TrimPrefix(authHeader, "Bearer ")
		} else {
			// Fall back to cookie (for same-origin / native apps)
			tokenStr = c.Cookies("AppsIDesaCookie")
		}

		if tokenStr == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized: No token provided",
			})
		}

		token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fiber.NewError(fiber.StatusUnauthorized, "Invalid token")
			}
			return []byte(os.Getenv("JWT_SECRET")), nil
		})
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized: Invalid token",
				"error":   err.Error(),
			})
		}

		if !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized: Token is not valid",
			})
		}

		// Extract claims and set village ID in context
		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			if villageID, exists := claims["village"]; exists {
				c.Locals("village", villageID)
			}
			// Absent on tokens issued before "username" was added to the claims;
			// those sessions log an empty actor rather than being rejected.
			if username, exists := claims["username"]; exists {
				c.Locals("username", username)
			}
		}

		return c.Next()
	}
}
