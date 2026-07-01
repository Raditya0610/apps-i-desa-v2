package routes

import (
	"Apps-I_Desa_Backend/controllers"
	"Apps-I_Desa_Backend/middleware"
	"Apps-I_Desa_Backend/repositories"
	"Apps-I_Desa_Backend/services"
	"github.com/gofiber/fiber/v2"
)

func SetupSubDimensionRoutes(app *fiber.App) {
	subDimensionRepo := repositories.NewSubDimensionRepository()
	subDimensionService := services.NewSubDimensionService(subDimensionRepo)
	subDimensionController := controllers.NewSubDimensionController(subDimensionService)

	api := app.Group("/api/sub-dimensions")

	// Apply JWT middleware to all sub-dimension routes
	api.Use(middleware.JWTAuth())

	// Pendidikan routes
	api.Get("/pendidikan", subDimensionController.GetPendidikan)
	api.Post("/pendidikan", subDimensionController.CreateSubDimensionPendidikan)
	api.Put("/pendidikan/:id", subDimensionController.UpdatePendidikan)
	api.Delete("/pendidikan/:id", subDimensionController.DeletePendidikan)

	// Kesehatan routes
	api.Get("/kesehatan", subDimensionController.GetKesehatan)
	api.Post("/kesehatan", subDimensionController.CreateSubDimensionKesehatan)
	api.Put("/kesehatan/:id", subDimensionController.UpdateKesehatan)
	api.Delete("/kesehatan/:id", subDimensionController.DeleteKesehatan)

	// Utilitas Dasar routes
	api.Get("/utilitas-dasar", subDimensionController.GetUtilitasDasar)
	api.Post("/utilitas-dasar", subDimensionController.CreateSubDimensionUtilitasDasar)
	api.Put("/utilitas-dasar/:id", subDimensionController.UpdateUtilitasDasar)
	api.Delete("/utilitas-dasar/:id", subDimensionController.DeleteUtilitasDasar)

	// Aktivitas routes
	api.Get("/aktivitas", subDimensionController.GetAktivitas)
	api.Post("/aktivitas", subDimensionController.CreateSubDimensionAktivitas)
	api.Put("/aktivitas/:id", subDimensionController.UpdateAktivitas)
	api.Delete("/aktivitas/:id", subDimensionController.DeleteAktivitas)

	// Fasilitas Masyarakat routes
	api.Get("/fasilitas-masyarakat", subDimensionController.GetFasilitasMasyarakat)
	api.Post("/fasilitas-masyarakat", subDimensionController.CreateSubDimensionFasilitasMasyarakat)
	api.Put("/fasilitas-masyarakat/:id", subDimensionController.UpdateFasilitasMasyarakat)
	api.Delete("/fasilitas-masyarakat/:id", subDimensionController.DeleteFasilitasMasyarakat)

	// Produksi Desa routes
	api.Get("/produksi-desa", subDimensionController.GetProduksiDesa)
	api.Post("/produksi-desa", subDimensionController.CreateSubDimensionProduksiDesa)
	api.Put("/produksi-desa/:id", subDimensionController.UpdateProduksiDesa)
	api.Delete("/produksi-desa/:id", subDimensionController.DeleteProduksiDesa)

	// Fasilitas Pendukung Ekonomi routes
	api.Get("/fasilitas-pendukung-ekonomi", subDimensionController.GetFasilitasPendukungEkonomi)
	api.Post("/fasilitas-pendukung-ekonomi", subDimensionController.CreateSubDimensionFasilitasPendukungEkonomi)
	api.Put("/fasilitas-pendukung-ekonomi/:id", subDimensionController.UpdateFasilitasPendukungEkonomi)
	api.Delete("/fasilitas-pendukung-ekonomi/:id", subDimensionController.DeleteFasilitasPendukungEkonomi)

	// Pengelolaan Lingkungan routes
	api.Get("/pengelolaan-lingkungan", subDimensionController.GetPengelolaanLingkungan)
	api.Post("/pengelolaan-lingkungan", subDimensionController.CreateSubDimensionPengelolaanLingkungan)
	api.Put("/pengelolaan-lingkungan/:id", subDimensionController.UpdatePengelolaanLingkungan)
	api.Delete("/pengelolaan-lingkungan/:id", subDimensionController.DeletePengelolaanLingkungan)

	// Penanggulangan Bencana routes
	api.Get("/penanggulangan-bencana", subDimensionController.GetPenanggulanganBencana)
	api.Post("/penanggulangan-bencana", subDimensionController.CreateSubDimensionPenanggulanganBencana)
	api.Put("/penanggulangan-bencana/:id", subDimensionController.UpdatePenanggulanganBencana)
	api.Delete("/penanggulangan-bencana/:id", subDimensionController.DeletePenanggulanganBencana)

	// Kondisi Akses Jalan routes
	api.Get("/kondisi-akses-jalan", subDimensionController.GetKondisiAksesJalan)
	api.Post("/kondisi-akses-jalan", subDimensionController.CreateSubDimensionKondisiAksesJalan)
	api.Put("/kondisi-akses-jalan/:id", subDimensionController.UpdateKondisiAksesJalan)
	api.Delete("/kondisi-akses-jalan/:id", subDimensionController.DeleteKondisiAksesJalan)

	// Kemudahan Akses routes
	api.Get("/kemudahan-akses", subDimensionController.GetKemudahanAkses)
	api.Post("/kemudahan-akses", subDimensionController.CreateSubDimensionKemudahanAkses)
	api.Put("/kemudahan-akses/:id", subDimensionController.UpdateKemudahanAkses)
	api.Delete("/kemudahan-akses/:id", subDimensionController.DeleteKemudahanAkses)

	// Kelembagaan Pelayanan Desa routes
	api.Get("/kelembagaan-pelayanan-desa", subDimensionController.GetKelembagaanPelayananDesa)
	api.Post("/kelembagaan-pelayanan-desa", subDimensionController.CreateSubDimensionKelembagaanPelayananDesa)
	api.Put("/kelembagaan-pelayanan-desa/:id", subDimensionController.UpdateKelembagaanPelayananDesa)
	api.Delete("/kelembagaan-pelayanan-desa/:id", subDimensionController.DeleteKelembagaanPelayananDesa)

	// Tata Kelola Keuangan Desa routes
	api.Get("/tata-kelola-keuangan-desa", subDimensionController.GetTataKelolaKeuanganDesa)
	api.Post("/tata-kelola-keuangan-desa", subDimensionController.CreateSubDimensionTataKelolaKeuanganDesa)
	api.Put("/tata-kelola-keuangan-desa/:id", subDimensionController.UpdateTataKelolaKeuanganDesa)
	api.Delete("/tata-kelola-keuangan-desa/:id", subDimensionController.DeleteTataKelolaKeuanganDesa)
}
