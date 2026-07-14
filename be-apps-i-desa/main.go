package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/routes"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

func setupRoutes(app *fiber.App) {
	routes.SetupUserRoutes(app)
	routes.SetupAuthRoutes(app)
	routes.SetupSubDimensionRoutes(app)
	routes.SetupVillagerRoutes(app)
	routes.SetupVillageRoutes(app)
	routes.SetupFamilyCardRoutes(app)
	routes.SetupDashboardRoutes(app)
	routes.SetupActivityLogRoutes(app)
}

func main() {
	// Must complete before setupRoutes: the repositories capture config.DB by
	// value at construction, so they would hold a nil handle forever if the
	// connection were established afterwards.
	if _, err := config.ConnectDB(); err != nil {
		log.Fatal("Database unavailable, refusing to start: ", err)
	}
	defer config.CloseDB()

	app := fiber.New(fiber.Config{
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": err.Error(),
			})
		},
	})

	app.Use(logger.New())
	app.Use(recover.New())

	allowedOrigins := os.Getenv("CORS_ALLOWED_ORIGINS")
	if allowedOrigins == "" {
		allowedOrigins = "http://localhost:3000,http://localhost:8080,http://localhost:5000"
	}
	app.Use(cors.New(cors.Config{
		AllowOrigins: allowedOrigins,
		AllowMethods: "GET,POST,PUT,DELETE,OPTIONS",
		// X-Admin-Token must be listed: the browser refuses to send a custom
		// header the preflight did not explicitly allow, so registration would
		// fail silently — the preflight returns 204 and the POST never leaves
		// the browser.
		AllowHeaders:     "Content-Type,Accept,Authorization," + middleware.AdminTokenHeader,
		AllowCredentials: true,
	}))

	// Health / keep-alive endpoint — ping this every 4 min from an external
	// cron (e.g. UptimeRobot free tier) to prevent Railway cold starts.
	// Reports the database separately so a DB outage is distinguishable from a
	// dead process without reading the logs.
	app.Get("/health", func(c *fiber.Ctx) error {
		if err := config.Ping(); err != nil {
			return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
				"status":   "degraded",
				"database": "unreachable",
				"error":    err.Error(),
			})
		}
		return c.JSON(fiber.Map{"status": "ok", "database": "ok"})
	})

	app.Get("/", func(ctx *fiber.Ctx) error {
		return ctx.SendString("Apps-I Desa API!")
	})

	// Registered before Listen: adding routes to a Fiber app that is already
	// serving is a race against its route tree.
	setupRoutes(app)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	go func() {
		if err := app.Listen(":" + port); err != nil {
			log.Fatal("Error starting server: ", err)
		}
	}()

	log.Printf("Server started on port %s", port)

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
	if err := app.Shutdown(); err != nil {
		log.Fatal("Server shutdown failed: ", err)
	}
}
