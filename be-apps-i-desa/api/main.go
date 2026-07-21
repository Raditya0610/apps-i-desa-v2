// Package handler provides the Vercel serverless function entrypoint
// for the Apps-I Desa Backend API.
//
// SERVERLESS BEST PRACTICES IMPLEMENTED:
//
//  1. Connection Reuse: The Fiber app and database connections are initialized
//     once using sync.Once and reused across function invocations. This dramatically
//     improves performance and reduces cold start times.
//
//  2. Database Connection Pooling: The database is configured with minimal
//     connection pooling (2 max open, 1 idle) suitable for serverless environments
//     where each function instance should use minimal resources.
//
//  3. No Port Listening: Unlike traditional servers, serverless functions don't
//     listen on ports. The Handler function is called by Vercel for each request.
//
//  4. HTTP Adapter: Uses gofiber/adaptor to convert Fiber's handler to the
//     standard http.Handler interface that Vercel expects.
//
// 5. Optimized Configuration:
//   - DisableStartupMessage: true (no console output needed)
//   - ReduceMemoryUsage: true (minimize memory footprint)
//   - Lightweight logging (only essential information)
//   - Connection timeouts aligned with Vercel's function duration limits
//
// DEPLOYMENT:
// 1. Ensure all environment variables are set in Vercel dashboard:
//   - DB_HOST, DB_USERNAME, DB_PASSWORD, DB_NAME, DB_PORT
//   - JWT_SECRET, JWT_EXPIRES_IN (if using JWT auth)
//
// 2. Deploy using Vercel CLI or Git integration:
//   - vercel --prod (for CLI deployment)
//   - Push to main branch (for Git integration)
//
// 3. The vercel.json configuration ensures all routes are handled by this function
package main

import (
	"errors"
	"net/http"
	"os"
	"sync"

	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/routes"
	"github.com/gofiber/adaptor/v2"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

var (
	app     *fiber.App
	once    sync.Once
	initErr error
)

// setupRoutes configures all application routes
func setupRoutes(app *fiber.App) {
	routes.SetupUserRoutes(app)
	routes.SetupAuthRoutes(app)
	routes.SetupSubDimensionRoutes(app)
	routes.SetupVillagerRoutes(app)
	routes.SetupVillageRoutes(app)
	routes.SetupFamilyCardRoutes(app)
	routes.SetupDashboardRoutes(app)
	routes.SetupActivityLogRoutes(app)
	routes.SetupImportRoutes(app)
}

// initializeApp initializes the Fiber app and database connection once
func initializeApp() (*fiber.App, error) {
	once.Do(func() {
		// Initialize database connection
		//  pooling is already configured in config.ConnectDB()
		// Bail out before setupRoutes: the repositories capture config.DB by value
		// at construction, so routes built on a failed connection would hold a nil
		// handle for the lifetime of this warm instance.
		if _, err := config.ConnectDB(); err != nil {
			initErr = err
			return
		}

		// Create Fiber app with configuration optimized for serverless
		app = fiber.New(fiber.Config{
			DisableStartupMessage: true,
			ReduceMemoryUsage:     true,
			// Default 4MB is too small for a village's full population
			// workbook (several hundred rows across two sheets, plus the
			// embedded DataValidation rules from the template). Must match
			// main.go's limit — if only one is raised, uploads work on one
			// platform and 413 on the other.
			BodyLimit: 15 * 1024 * 1024,
			ErrorHandler: func(c *fiber.Ctx, err error) error {
				code := fiber.StatusInternalServerError
				var e *fiber.Error
				if errors.As(err, &e) {
					code = e.Code
				}
				return c.Status(code).JSON(fiber.Map{
					"error": err.Error(),
				})
			},
		})

		// Configure middleware
		app.Use(recover.New(recover.Config{
			EnableStackTrace: true,
		}))

		// Logger middleware - lightweight for serverless
		app.Use(logger.New(logger.Config{
			Format:     "${time} ${status} - ${method} ${path}\n",
			TimeFormat: "15:04:05",
			TimeZone:   "UTC",
		}))

		// CORS middleware
		allowedOrigins := os.Getenv("ALLOWED_ORIGINS")
		if allowedOrigins == "" {
			allowedOrigins = "http://localhost:3000,http://localhost:8080,http://localhost:5000"
		}
		app.Use(cors.New(cors.Config{
			AllowOrigins: allowedOrigins,
			AllowMethods: "GET,POST,PUT,DELETE,OPTIONS",
			// X-Admin-Token must be listed: the browser refuses to send a custom
			// header the preflight did not explicitly allow, so registration would
			// fail silently.
			AllowHeaders:     "Content-Type,Accept,Authorization," + middleware.AdminTokenHeader,
			AllowCredentials: true,
		}))

		// Setup all routes
		setupRoutes(app)

		// Health check endpoint
		app.Get("/", func(c *fiber.Ctx) error {
			return c.JSON(fiber.Map{
				"message": "Apps-I Desa API",
				"status":  "healthy",
			})
		})

		// API health check
		app.Get("/health", func(c *fiber.Ctx) error {
			return c.JSON(fiber.Map{
				"status": "ok",
			})
		})
	})

	return app, initErr
}

// Handler is the entrypoint for Vercel serverless function
// This function is called on every request
func Handler(w http.ResponseWriter, r *http.Request) {
	// Initialize app once and reuse across requests
	app, err := initializeApp()
	if err != nil {
		http.Error(w, "Internal Server Error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	if r.URL.RawQuery != "" && r.RequestURI != "" && !containsQueryString(r.RequestURI) {
		r.RequestURI = r.RequestURI + "?" + r.URL.RawQuery
	}
	// Convert Fiber handler to http.Handler and serve the request
	adaptor.FiberApp(app)(w, r)
}

// Helper function to check if RequestURI already contains query string
func containsQueryString(uri string) bool {
	for i := 0; i < len(uri); i++ {
		if uri[i] == '?' {
			return true
		}
	}
	return false
}
