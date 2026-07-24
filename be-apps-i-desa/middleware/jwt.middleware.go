package middleware

import (
	"os"
	"strings"

	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

func JWTAuth() fiber.Handler {
	// Constructed once when the route is set up, reused across every request
	// this middleware handles — not per-request, matching how other route
	// setups build their repositories/services once.
	userRepo := repositories.NewUserRepository()

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

		// Fail closed, matching AdminToken's own handling of its secret: an
		// unset JWT_SECRET must not silently become an empty-string HMAC key,
		// since Go's HMAC accepts an empty key without error — that would let
		// anyone self-sign an arbitrary token (any username/village/session_id)
		// the moment this env var is ever missing in a deployed environment.
		secret := os.Getenv("JWT_SECRET")
		if secret == "" {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Server misconfigured: JWT_SECRET is not set",
			})
		}

		token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fiber.NewError(fiber.StatusUnauthorized, "Invalid token")
			}
			return []byte(secret), nil
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

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized: Invalid token",
			})
		}

		if villageID, exists := claims["village"]; exists {
			c.Locals("village", villageID)
		}

		// Single-device enforcement needs to know which account's session to
		// check, so username is required from here on — tokens issued before
		// "username"/"session_id" were added to the claims fail this check and
		// force a one-time re-login rather than being silently trusted.
		username, hasUsername := claims["username"].(string)
		sessionID, hasSessionID := claims["session_id"].(string)
		if !hasUsername || !hasSessionID {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized: Session expired, please log in again",
			})
		}
		c.Locals("username", username)

		// Reject any token whose session_id no longer matches the account's
		// current session. A newer login overwrites the stored session_id (see
		// AuthService.Login), so this is what actually forces a previously
		// logged-in device out — the token itself doesn't otherwise know it's
		// been superseded.
		user, err := userRepo.FindByUsername(username)
		if err != nil || user.SessionID.String() != sessionID {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized: Logged in on another device",
			})
		}

		return c.Next()
	}
}
