package config

import (
	"fmt"
	"os"
	"time"

	models2 "Apps-I_Desa_Backend/models"
	"github.com/gofiber/fiber/v2/log"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/schema"
)

// DB is a global variable that holds the database connection
var DB *gorm.DB

// Connection is retried rather than attempted once: on Railway the container's
// DNS resolver is not ready the instant the process starts, so the first lookup
// of the Aiven host can fail with "no such host" even though the host is fine.
// Dying on that first failure turned a sub-second startup race into a crash
// loop, which took down every route — including /health — with no logs at all.
const (
	dbConnectAttempts = 10
	dbRetryBaseDelay  = 1 * time.Second
	dbRetryMaxDelay   = 15 * time.Second
)

// ConnectDB establishes the database connection, retrying with backoff, and runs
// migrations. It returns an error instead of exiting so the caller decides what a
// permanently unreachable database means.
func ConnectDB() (*gorm.DB, error) {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Warn("Error loading .env file, using environment variables")
	}

	dsn, err := buildDSN()
	if err != nil {
		return nil, err
	}

	var lastErr error
	delay := dbRetryBaseDelay

	for attempt := 1; attempt <= dbConnectAttempts; attempt++ {
		db, err := openDB(dsn)
		if err == nil {
			DB = db
			log.Info("Successfully connected to the database")

			if err := migrateDB(DB); err != nil {
				return nil, fmt.Errorf("database migration failed: %w", err)
			}
			return DB, nil
		}

		lastErr = err
		log.Warnf("Database connection attempt %d/%d failed: %v", attempt, dbConnectAttempts, err)

		if attempt < dbConnectAttempts {
			time.Sleep(delay)
			if delay *= 2; delay > dbRetryMaxDelay {
				delay = dbRetryMaxDelay
			}
		}
	}

	return nil, fmt.Errorf("database unreachable after %d attempts: %w", dbConnectAttempts, lastErr)
}

// buildDSN prefers DATABASE_URL (Railway/Aiven style), falling back to individual vars.
func buildDSN() (string, error) {
	if url := os.Getenv("DATABASE_URL"); url != "" {
		return url, nil
	}

	requiredEnvVars := []string{"DB_HOST", "DB_USERNAME", "DB_PASSWORD", "DB_NAME", "DB_PORT"}
	for _, envVar := range requiredEnvVars {
		if os.Getenv(envVar) == "" {
			return "", fmt.Errorf("required environment variable %s is not set", envVar)
		}
	}

	sslMode := os.Getenv("DB_SSL")
	if sslMode == "" {
		sslMode = "disable"
	}
	timeZone := os.Getenv("DB_TIMEZONE")
	if timeZone == "" {
		timeZone = "UTC"
	}

	return fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s TimeZone=%s",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USERNAME"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
		sslMode,
		timeZone,
	), nil
}

// openDB opens a connection, configures the pool, and verifies the connection is
// actually usable before reporting success.
func openDB(dsn string) (*gorm.DB, error) {
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		NamingStrategy: schema.NamingStrategy{
			TablePrefix:   "",
			SingularTable: false,
		},
	})
	if err != nil {
		return nil, err
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get database connection pool: %w", err)
	}

	// Dashboard fires 9 concurrent queries; pool must be >= 9 so goroutines
	// run in parallel rather than queuing 2-at-a-time.
	// Aiven free tier allows 25 connections total, so 15 is safe for 1 instance.
	sqlDB.SetMaxOpenConns(15)
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetConnMaxLifetime(30 * time.Minute)
	sqlDB.SetConnMaxIdleTime(10 * time.Minute)

	// gorm.Open can return before a connection is actually established; ping so a
	// retryable failure surfaces here rather than on the first user request.
	if err := sqlDB.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}

// Ping reports whether the database is currently reachable. Used by /health so a
// database outage is visible without having to read application logs.
func Ping() error {
	if DB == nil {
		return fmt.Errorf("database not initialized")
	}
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}
	return sqlDB.Ping()
}

func migrateDB(db *gorm.DB) error {
	m := []interface{}{
		&models2.User{},
		&models2.Village{},
		&models2.Villager{},
		&models2.FamilyCard{},
		&models2.ActivityLog{},
		&models2.SubDimensiAktivitas{},
		&models2.SubDimensiFasilitasMasyarakat{},
		&models2.SubDimensiFasilitasPendukungEkonomi{},
		&models2.SubDimensiKelembagaanPelayananDesa{},
		&models2.SubDimensiKemudahanAkses{},
		&models2.SubDimensiKondisiAksesJalan{},
		&models2.SubDimensiPendidikan{},
		&models2.SubDimensiKesehatan{},
		&models2.SubDimensiUtilitasDasar{},
		&models2.SubDimensiProduksiDesa{},
		&models2.SubDimensiPengelolaanLingkungan{},
		&models2.SubDimensiPenanggulanganBencana{},
		&models2.SubDimensiTataKelolaKeuanganDesa{},
	}

	return db.AutoMigrate(m...)
}

func CloseDB() {
	if DB != nil {
		sqlDB, err := DB.DB()
		if err != nil {
			log.Error("Failed to get database connection: ", err)
			return
		}
		if err := sqlDB.Close(); err != nil {
			log.Error("Error closing database connection: ", err)
		} else {
			log.Info("Database connection closed")
		}
	}
}
