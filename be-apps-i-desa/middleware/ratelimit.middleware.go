package middleware

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/limiter"
)

// AuthRateLimiter throttles credential-sensitive endpoints (login, register) to
// blunt brute-force: password guessing on login, and registration-code guessing
// on register. Keyed on client IP — which is the real client only because
// main.go sets ProxyHeader; without that every request would share the proxy IP
// and one attacker would throttle all users.
//
// Each call returns a limiter with its own in-memory counter, so login and
// register get independent budgets. In-memory is fine on Railway (one long-lived
// process); it would reset per-invocation on a serverless host.
func AuthRateLimiter() fiber.Handler {
	return limiter.New(limiter.Config{
		Max:        10,
		Expiration: 1 * time.Minute,
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"message": "Terlalu banyak percobaan. Silakan coba lagi dalam 1 menit.",
			})
		},
	})
}
