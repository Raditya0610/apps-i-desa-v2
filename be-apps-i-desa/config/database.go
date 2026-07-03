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

// ConnectDB initializes the database connection and returns it
func ConnectDB() *gorm.DB {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Warn("Error loading .env file, using environment variables")
	}

	// Build DSN: prefer DATABASE_URL (Railway/Aiven style), fall back to individual vars
	var dsn string
	if url := os.Getenv("DATABASE_URL"); url != "" {
		dsn = url
	} else {
		requiredEnvVars := []string{"DB_HOST", "DB_USERNAME", "DB_PASSWORD", "DB_NAME", "DB_PORT"}
		for _, envVar := range requiredEnvVars {
			if os.Getenv(envVar) == "" {
				log.Fatalf("Required environment variable %s is not set", envVar)
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

		dsn = fmt.Sprintf(
			"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s TimeZone=%s",
			os.Getenv("DB_HOST"),
			os.Getenv("DB_USERNAME"),
			os.Getenv("DB_PASSWORD"),
			os.Getenv("DB_NAME"),
			os.Getenv("DB_PORT"),
			sslMode,
			timeZone,
		)
	}

	// Connect to the database
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		NamingStrategy: schema.NamingStrategy{
			TablePrefix:   "",
			SingularTable: false,
		},
	})
	if err != nil {
		log.Fatal("Failed to connect to the database: ", err)
	}

	// Configure connection pool
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatal("Failed to get database connection pool: ", err)
	}

	// Dashboard fires 9 concurrent queries; pool must be >= 9 so goroutines
	// run in parallel rather than queuing 2-at-a-time.
	// Aiven free tier allows 25 connections total, so 15 is safe for 1 instance.
	sqlDB.SetMaxOpenConns(15)
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetConnMaxLifetime(30 * time.Minute)
	sqlDB.SetConnMaxIdleTime(10 * time.Minute)

	// Run migrations
	if err := migrateDB(DB); err != nil {
		log.Fatal("Database migration failed: ", err)
	}

	log.Info("Successfully connected to the database")
	return DB
}

func migrateDB(db *gorm.DB) error {
	m := []interface{}{
		&models2.User{},
		&models2.Village{},
		&models2.Villager{},
		&models2.FamilyCard{},
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
