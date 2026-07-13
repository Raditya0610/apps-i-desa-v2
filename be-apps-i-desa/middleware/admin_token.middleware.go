package middleware

import (
	"crypto/subtle"
	"os"

	"github.com/gofiber/fiber/v2"
)

// AdminTokenHeader carries the shared registration secret.
const AdminTokenHeader = "X-Admin-Token"

// AdminToken guards account registration.
//
// Registration cannot require an existing session — it is how the first account
// for a village gets made — so before this it was open to anyone on the internet.
// That was not protected by the village UUID being hard to guess: the UUIDs were
// hardcoded in the frontend and compiled into the public JS bundle. Anyone who
// loaded the site could register into a real ohoi and read villager PII (names,
// addresses, NIK).
//
// This is a single shared secret the developer hands to the desa operator, along
// with the village row they insert by hand. It is not an identity system; it is
// the smallest thing that turns an open endpoint into a closed one.
func AdminToken() fiber.Handler {
	return func(c *fiber.Ctx) error {
		expected := os.Getenv("ADMIN_REGISTRATION_TOKEN")

		// Fail closed. An unset secret must not silently reopen registration —
		// that is the exact state this middleware exists to prevent.
		if expected == "" {
			return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
				"message": "Pendaftaran dinonaktifkan: ADMIN_REGISTRATION_TOKEN belum diatur di server",
			})
		}

		provided := c.Get(AdminTokenHeader)

		// Constant-time compare so response timing cannot be used to recover the
		// token byte by byte.
		if subtle.ConstantTimeCompare([]byte(provided), []byte(expected)) != 1 {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Kode pendaftaran tidak valid",
			})
		}

		return c.Next()
	}
}
