package services

import (
	"errors"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"github.com/google/uuid"
)

type SubDimensionService struct {
	subDimensionRepo *repositories.SubDimensionRepository
}

func NewSubDimensionService(
	subDimensionRepo *repositories.SubDimensionRepository,
) *SubDimensionService {
	return &SubDimensionService{
		subDimensionRepo: subDimensionRepo,
	}
}

func (s *SubDimensionService) CreateSubDimensionPendidikan(
	req *dtos.AddSubDimensionPendidikanRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	subDimensiPendidikan := &models.SubDimensiPendidikan{
		VillageID:          villageID,
		Year:               *req.Year,
		KetersediaanPaud:   req.KetersediaanPaud,
		KemudahanAksesPaud: req.KemudahanAksesPaud,
		ApmPaud:            req.ApmPaud,
		KemudahanAksesSd:   req.KemudahanAksesSd,
		ApmSd:              req.ApmSd,
		KemudahanAksesSmp:  req.KemudahanAksesSmp,
		ApmSmp:             req.ApmSmp,
		KemudahanAksesSma:  req.KemudahanAksesSma,
		ApmSma:             req.ApmSma,
	}
	if err := s.subDimensionRepo.CreateSubDimensionPendidikanWithTx(tx, subDimensiPendidikan); err != nil {
		log.Error("Error creating sub dimension pendidikan:", err)
		return nil, errors.New("failed to create sub dimension pendidikan")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}
	return &dtos.MessageResponse{
		Message: "Sub Dimension Pendidikan created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionKesehatan(
	req *dtos.AddSubDimensionKesehatanRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	subDimensiKesehatan := &models.SubDimensiKesehatan{
		VillageID:                                  villageID,
		Year:                                       *req.Year,
		KemudahanAksesSaranaKesehatan:              req.KemudahanAksesSaranaKesehatan,
		KetersediaanFasilitasKesehatan:             req.KetersediaanFasilitasKesehatan,
		KemudahanAksesFasilitasKesehatan:           req.KemudahanAksesFasilitasKesehatan,
		KetersediaanPosyandu:                       req.KetersediaanPosyandu,
		JumlahAktivitasPosyandu:                    req.JumlahAktivitasPosyandu,
		KemudahanAksesPosyandu:                     req.KemudahanAksesPosyandu,
		KetersediaanLayananDokter:                  req.KetersediaanLayananDokter,
		HariOperasionalLayananDokter:               req.HariOperasionalLayananDokter,
		PenyediaLayananDokter:                      req.PenyediaLayananDokter,
		PenyediaTransportasiLayananDokter:          req.PenyediaTransportasiLayananDokter,
		KetersediaanLayananBidan:                   req.KetersediaanLayananBidan,
		HariOperasionalLayananBidan:                req.HariOperasionalLayananBidan,
		PenyediaLayananBidan:                       req.PenyediaLayananBidan,
		PenyediaTransportasiLayananBidan:           req.PenyediaTransportasiLayananBidan,
		KetersediaanLayananTenagaKesehatan:         req.KetersediaanLayananTenagaKesehatan,
		HariOperasionalLayananTenagaKesehatan:      req.HariOperasionalLayananTenagaKesehatan,
		PenyediaLayananTenagaKesehatan:             req.PenyediaLayananTenagaKesehatan,
		PenyediaTransportasiLayananTenagaKesehatan: req.PenyediaTransportasiLayananTenagaKesehatan,
		PersentasePesertaJaminanKesehatan:          req.PersentasePesertaJaminanKesehatan,
		KegiatanSosialisasiJaminanKesehatan:        req.KegiatanSosialisasiJaminanKesehatan,
	}

	if err := s.subDimensionRepo.CreateSubDimensionKesehatanWithTx(tx, subDimensiKesehatan); err != nil {
		log.Error("Error creating sub dimension kesehatan:", err)
		return nil, errors.New("failed to create sub dimension kesehatan")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}
	return &dtos.MessageResponse{
		Message: "Sub Dimension Kesehatan created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionUtilitasDasar(
	req *dtos.AddSubDimensionUtilitasDasarRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	subDimensiUtilitasDasar := &models.SubDimensiUtilitasDasar{
		VillageID:                     villageID,
		Year:                          *req.Year,
		OperasionalAirMinum:           req.OperasionalAirMinum,
		KetersediaanAirMinum:          req.KetersediaanAirMinum,
		KemudahanAksesAirMinum:        req.KemudahanAksesAirMinum,
		KualitasAirMinum:              req.KualitasAirMinum,
		PersentaseRumahTidakLayakHuni: req.PersentaseRumahTidakLayakHuni,
	}
	if err := s.subDimensionRepo.CreateSubDimensionUtilitasDasarWithTx(tx, subDimensiUtilitasDasar); err != nil {
		log.Error("Error creating sub dimension utilitas dasar:", err)
		return nil, errors.New("failed to create sub dimension utilitas dasar")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Utilitas Dasar created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionAktivitas(
	req *dtos.AddSubDimensionAktivitasRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	subDimensiAktivitas := &models.SubDimensiAktivitas{
		VillageID:                         villageID,
		Year:                              *req.Year,
		KearifanBudayaSosial:              req.KearifanBudayaSosial,
		KearifanBudayaSosialDipertahankan: req.KearifanBudayaSosialDipertahankan,
		KegiatanGotongRoyong:              req.KegiatanGotongRoyong,
		FrekuensiGotongRoyong:             req.FrekuensiGotongRoyong,
		KeterlibatanWargaGotongRoyong:     req.KeterlibatanWargaGotongRoyong,
		FrekuensiKegiatanOlahraga:         req.FrekuensiKegiatanOlahraga,
		PenyelesaianKonflikSecaraDamai:    req.PenyelesaianKonflikSecaraDamai,
		PeranAparatKeamananMediator:       req.PeranAparatKeamananMediator,
		PeranAparatPemerintah:             req.PeranAparatPemerintah,
		PeranTokohMasyarakat:              req.PeranTokohMasyarakat,
		PeranTokohAgama:                   req.PeranTokohAgama,
		SatuanKeamananLingkungan:          req.SatuanKeamananLingkungan,
		AktivitasSatuanKeamananLingkungan: req.AktivitasSatuanKeamananLingkungan,
	}

	if err := s.subDimensionRepo.CreateSubDimensionAktivitasWithTx(tx, subDimensiAktivitas); err != nil {
		log.Error("Error creating sub dimension aktivitas:", err)
		return nil, errors.New("failed to create sub dimension aktivitas")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Aktivitas created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionFasilitasMasyarakat(
	req *dtos.AddSubDimensionFasilitasMasyarakatRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	subDimensiFasilitasMasyarakat := &models.SubDimensiFasilitasMasyarakat{
		VillageID:                            villageID,
		Year:                                 *req.Year,
		TerdapatTamanBacaanMasyarakat:        req.TerdapatTamanBacaanMasyarakat,
		HariOperasionalTamanBacaanMasyarakat: req.HariOperasionalTamanBacaanMasyarakat,
		KetersediaanFasilitasOlahraga:        req.KetersediaanFasilitasOlahraga,
		KeberadaanRuangPublikTerbuka:         req.KeberadaanRuangPublikTerbuka,
	}
	if err := s.subDimensionRepo.CreateSubDimensionFasilitasMasyarakatWithTx(tx, subDimensiFasilitasMasyarakat); err != nil {
		log.Error("Error creating sub dimension fasilitas masyarakat:", err)
		return nil, errors.New("failed to create sub dimension fasilitas masyarakat")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Fasilitas Masyarakat created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionProduksiDesa(
	req *dtos.AddSubDimensionProduksiDesaRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	subDimensiPendidikan := &models.SubDimensiProduksiDesa{
		VillageID:                                villageID,
		Year:                                     *req.Year,
		KeragamanAktivitasEkonomi:                req.KeragamanAktivitasEkonomi,
		KeaktifanAktivitasEkonomi:                req.KeaktifanAktivitasEkonomi,
		KetersediaanProdukUnggulanDesa:           req.KetersediaanProdukUnggulanDesa,
		CakupanPasarProdukUnggulan:               req.CakupanPasarProdukUnggulan,
		KetersediaanMerekDagang:                  req.KetersediaanMerekDagang,
		TerdapatKearifanLokalEkonomi:             req.TerdapatKearifanLokalEkonomi,
		TelahDilakukanKerjaSamaDenganDesaLainnya: req.TelahDilakukanKerjaSamaDenganDesaLainnya,
		TelahDilakukanKerjaSamaDenganPihakKetiga: req.TelahDilakukanKerjaSamaDenganPihakKetiga,
	}

	if err := s.subDimensionRepo.CreateSubDimensionProduksiDesaWithTx(tx, subDimensiPendidikan); err != nil {
		log.Error("Error creating sub dimension produksi desa:", err)
		return nil, errors.New("failed to create sub dimension produksi desa")
	}
	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Produksi Desa created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionFasilitasPendukungEkonomi(
	req *dtos.AddSubDimensionFasilitasPendukungEkonomiRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiFasilitasPendukungEkonomi{
		VillageID:                         villageID,
		Year:                              *req.Year,
		KetersediaanPendidikanNonFormal:   req.KetersediaanPendidikanNonFormal,
		KeterlibatanPendidikanNonFormal:   req.KeterlibatanPendidikanNonFormal,
		KetersediaanPasarRakyat:           req.KetersediaanPasarRakyat,
		KemudahanAksesPasarRakyat:         req.KemudahanAksesPasarRakyat,
		KetersediaanToko:                  req.KetersediaanToko,
		KemudahanAksesToko:                req.KemudahanAksesToko,
		KetersediaanRumahMakan:            req.KetersediaanRumahMakan,
		KemudahanAksesRumahMakan:          req.KemudahanAksesRumahMakan,
		KetersediaanPenginapan:            req.KetersediaanPenginapan,
		KemudahanAksesPenginapan:          req.KemudahanAksesPenginapan,
		KetersediaanLogistik:              req.KetersediaanLogistik,
		KemudahanAksesLogistik:            req.KemudahanAksesLogistik,
		TerdapatBumd:                      req.TerdapatBumd,
		BumdBerbadanHukum:                 req.BumdBerbadanHukum,
		HariOperasionalLembagaEkonomi:     req.HariOperasionalLembagaEkonomi,
		KetersediaanLembagaEkonomiLainnya: req.KetersediaanLembagaEkonomiLainnya,
		KetersediaanKud:                   req.KetersediaanKud,
		KetersediaanUmkm:                  req.KetersediaanUmkm,
		LayananPerbankan:                  req.LayananPerbankan,
		HariOperasionalKeuangan:           req.HariOperasionalKeuangan,
		LayananFasilitasKreditKur:         req.LayananFasilitasKreditKur,
		LayananFasilitasKreditKkpE:        req.LayananFasilitasKreditKkpE,
		LayananFasilitasKreditKuk:         req.LayananFasilitasKreditKuk,
		StatusLayananFasilitasKredit:      req.StatusLayananFasilitasKredit,
	}

	if err := s.subDimensionRepo.CreateSubDimensionFasilitasPendukungEkonomiWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension fasilitas pendukung ekonomi:", err)
		return nil, errors.New("failed to create sub dimension fasilitas pendukung ekonomi")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Fasilitas Pendukung Ekonomi created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionPengelolaanLingkungan(
	req *dtos.AddSubDimensionPengelolaanLingkunganRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiPengelolaanLingkungan{
		VillageID:                         villageID,
		Year:                              *req.Year,
		UpayaMenjagaKelestarianLingkungan: req.UpayaMenjagaKelestarianLingkungan,
		RegulasiPelestarianLingkungan:     req.RegulasiPelestarianLingkungan,
		KegiatanPelestarianLingkungan:     req.KegiatanPelestarianLingkungan,
		PemanfaatanEnergiTerbarukan:       req.PemanfaatanEnergiTerbarukan,
		TempatPembuananganSampah:          req.TempatPembuananganSampah,
		PengelolaanSampah:                 req.PengelolaanSampah,
		PemanfaatanSampah:                 req.PemanfaatanSampah,
		KejadianPencemaranLingkungan:      req.KejadianPencemaranLingkungan,
		KetersediaanJamban:                req.KetersediaanJamban,
		KeberfungsianJamban:               req.KeberfungsianJamban,
		KetersediaanSepticTank:            req.KetersediaanSepticTank,
		PembuanganAirLimbahCairRumah:      req.PembuanganAirLimbahCairRumah,
	}

	if err := s.subDimensionRepo.CreateSubDimensionPengelolaanLingkunganWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension pengelolaan lingkungan:", err)
		return nil, errors.New("failed to create sub dimension pengelolaan lingkungan")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Pengelolaan Lingkungan created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionPenanggulanganBencana(
	req *dtos.AddSubDimensionPenanggulanganBencanaRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiPenanggulanganBencana{
		VillageID:                           villageID,
		Year:                                *req.Year,
		AspekInformasiKebencanaan:           req.AspekInformasiKebencanaan,
		FasilitasMitigasiBencana:            req.FasilitasMitigasiBencana,
		AksesMenujuFasilitasMitigasiBencana: req.AksesMenujuFasilitasMitigasiBencana,
		AktivitasMitigasi:                   req.AktivitasMitigasi,
		FasilitasTanggapDaruratBencana:      req.FasilitasTanggapDaruratBencana,
	}

	if err := s.subDimensionRepo.CreateSubDimensionPenanggulanganBencanaWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension penanggulangan bencana:", err)
		return nil, errors.New("failed to create sub dimension penanggulangan bencana")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Penanggulangan Bencana created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionKondisiAksesJalan(
	req *dtos.AddSubDimensionKondisiAksesJalanRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiKondisiAksesJalan{
		VillageID:            villageID,
		Year:                 *req.Year,
		JenisPermukaanJalan:  req.JenisPermukaanJalan,
		KualitasJalan:        req.KualitasJalan,
		PeneranganJalanUtama: req.PeneranganJalanUtama,
		OperasionalPju:       req.OperasionalPju,
	}

	if err := s.subDimensionRepo.CreateSubDimensionKondisiAksesJalanWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension kondisi akses jalan:", err)
		return nil, errors.New("failed to create sub dimension kondisi akses jalan")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Kondisi Akses Jalan created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionKemudahanAkses(
	req *dtos.AddSubDimensionKemudahanAksesRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiKemudahanAkses{
		VillageID:                    villageID,
		Year:                         *req.Year,
		AngkutanPerdesaan:            req.AngkutanPerdesaan,
		OperasionalAngkutanPerdesaan: req.OperasionalAngkutanPerdesaan,
		PelayananListrik:             req.PelayananListrik,
		DurasiLayananListrik:         req.DurasiLayananListrik,
		AksesTelepon:                 req.AksesTelepon,
		AksesInternet:                req.AksesInternet,
	}

	if err := s.subDimensionRepo.CreateSubDimensionKemudahanAksesWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension kemudahan akses:", err)
		return nil, errors.New("failed to create sub dimension kemudahan akses")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Kemudahan Akses created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionKelembagaanPelayananDesa(
	req *dtos.AddSubDimensionKelembagaanPelayananDesaRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiKelembagaanPelayananDesa{
		VillageID:                              villageID,
		Year:                                   *req.Year,
		LayananDiberikan:                       req.LayananDiberikan,
		PublikasiInformasiPelayanan:            req.PublikasiInformasiPelayanan,
		PelayananAdministrasi:                  req.PelayananAdministrasi,
		PelayananPengaduan:                     req.PelayananPengaduan,
		PelayananLainnya:                       req.PelayananLainnya,
		MusyawarahDesa:                         req.MusyawarahDesa,
		MusyawarahDesaDidatangiUnsurMasyarakat: req.MusyawarahDesaDidatangiUnsurMasyarakat,
	}

	if err := s.subDimensionRepo.CreateSubDimensionKelembagaanPelayananDesaWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension kelembagaan pelayanan desa:", err)
		return nil, errors.New("failed to create sub dimension kelembagaan pelayanan desa")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Kelembagaan Pelayanan Desa created successfully",
	}, nil
}

func (s *SubDimensionService) CreateSubDimensionTataKelolaKeuanganDesa(
	req *dtos.AddSubDimensionTataKelolaKeuanganDesaRequest,
	ctx *fiber.Ctx,
) (*dtos.MessageResponse, error) {
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()

	villageIDStr := ctx.Locals("village").(string)
	// Parse the village ID from the context
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID not found")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID")
	}

	model := &models.SubDimensiTataKelolaKeuanganDesa{
		VillageID:             villageID,
		Year:                  *req.Year,
		PendapatanAsliDesa:    req.PendapatanAsliDesa,
		PeningkatanPades:      req.PeningkatanPades,
		PenyertaanModalDdBumd: req.PenyertaanModalDdBumd,
		AsetTanahDesa:         req.AsetTanahDesa,
		AsetKantorDesa:        req.AsetKantorDesa,
		AsetPasarDesa:         req.AsetPasarDesa,
		AsetLainnya:           req.AsetLainnya,
		ProduktivitasAsetDesa: req.ProduktivitasAsetDesa,
		InventarisasiAsetDesa: req.InventarisasiAsetDesa,
	}

	if err := s.subDimensionRepo.CreateSubDimensionTataKelolaKeuanganDesaWithTx(tx, model); err != nil {
		log.Error("Error creating sub dimension tata kelola keuangan desa:", err)
		return nil, errors.New("failed to create sub dimension tata kelola keuangan desa")
	}

	if err := tx.Commit().Error; err != nil {
		log.Error("Error committing transaction:", err)
		return nil, errors.New("failed to commit transaction")
	}

	return &dtos.MessageResponse{
		Message: "Sub Dimension Tata Kelola Keuangan Desa created successfully",
	}, nil
}

// ── helpers ───────────────────────────────────────────────────────────────────

func (s *SubDimensionService) villageIDFromCtx(ctx *fiber.Ctx) (uuid.UUID, error) {
	str := ctx.Locals("village").(string)
	if str == "" {
		return uuid.Nil, errors.New("village ID not found")
	}
	id, err := uuid.Parse(str)
	if err != nil {
		return uuid.Nil, errors.New("invalid village ID")
	}
	return id, nil
}

func parseID(raw string) (uuid.UUID, error) {
	id, err := uuid.Parse(raw)
	if err != nil {
		return uuid.Nil, errors.New("invalid ID")
	}
	return id, nil
}

// ── GET ───────────────────────────────────────────────────────────────────────

func (s *SubDimensionService) GetPendidikan(ctx *fiber.Ctx) ([]*models.SubDimensiPendidikan, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllPendidikanByVillage(vid)
}

func (s *SubDimensionService) GetKesehatan(ctx *fiber.Ctx) ([]*models.SubDimensiKesehatan, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllKesehatanByVillage(vid)
}

func (s *SubDimensionService) GetUtilitasDasar(ctx *fiber.Ctx) ([]*models.SubDimensiUtilitasDasar, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllUtilitasDasarByVillage(vid)
}

func (s *SubDimensionService) GetAktivitas(ctx *fiber.Ctx) ([]*models.SubDimensiAktivitas, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllAktivitasByVillage(vid)
}

func (s *SubDimensionService) GetFasilitasMasyarakat(ctx *fiber.Ctx) ([]*models.SubDimensiFasilitasMasyarakat, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllFasilitasMasyarakatByVillage(vid)
}

func (s *SubDimensionService) GetProduksiDesa(ctx *fiber.Ctx) ([]*models.SubDimensiProduksiDesa, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllProduksiDesaByVillage(vid)
}

func (s *SubDimensionService) GetFasilitasPendukungEkonomi(ctx *fiber.Ctx) ([]*models.SubDimensiFasilitasPendukungEkonomi, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllFasilitasPendukungEkonomiByVillage(vid)
}

func (s *SubDimensionService) GetPengelolaanLingkungan(ctx *fiber.Ctx) ([]*models.SubDimensiPengelolaanLingkungan, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllPengelolaanLingkunganByVillage(vid)
}

func (s *SubDimensionService) GetPenanggulanganBencana(ctx *fiber.Ctx) ([]*models.SubDimensiPenanggulanganBencana, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllPenanggulanganBencanaByVillage(vid)
}

func (s *SubDimensionService) GetKondisiAksesJalan(ctx *fiber.Ctx) ([]*models.SubDimensiKondisiAksesJalan, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllKondisiAksesJalanByVillage(vid)
}

func (s *SubDimensionService) GetKemudahanAkses(ctx *fiber.Ctx) ([]*models.SubDimensiKemudahanAkses, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllKemudahanAksesByVillage(vid)
}

func (s *SubDimensionService) GetKelembagaanPelayananDesa(ctx *fiber.Ctx) ([]*models.SubDimensiKelembagaanPelayananDesa, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllKelembagaanPelayananDesaByVillage(vid)
}

func (s *SubDimensionService) GetTataKelolaKeuanganDesa(ctx *fiber.Ctx) ([]*models.SubDimensiTataKelolaKeuanganDesa, error) {
	vid, err := s.villageIDFromCtx(ctx)
	if err != nil {
		return nil, err
	}
	return s.subDimensionRepo.GetAllTataKelolaKeuanganDesaByVillage(vid)
}

// ── DELETE ────────────────────────────────────────────────────────────────────

func (s *SubDimensionService) DeletePendidikan(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindPendidikanByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeletePendidikanByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteKesehatan(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindKesehatanByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteKesehatanByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteUtilitasDasar(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindUtilitasDasarByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteUtilitasDasarByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteAktivitas(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindAktivitasByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteAktivitasByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteFasilitasMasyarakat(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindFasilitasMasyarakatByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteFasilitasMasyarakatByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteProduksiDesa(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindProduksiDesaByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteProduksiDesaByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteFasilitasPendukungEkonomi(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindFasilitasPendukungEkonomiByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteFasilitasPendukungEkonomiByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeletePengelolaanLingkungan(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindPengelolaanLingkunganByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeletePengelolaanLingkunganByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeletePenanggulanganBencana(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindPenanggulanganBencanaByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeletePenanggulanganBencanaByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteKondisiAksesJalan(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindKondisiAksesJalanByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteKondisiAksesJalanByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteKemudahanAkses(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindKemudahanAksesByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteKemudahanAksesByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteKelembagaanPelayananDesa(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindKelembagaanPelayananDesaByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteKelembagaanPelayananDesaByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) DeleteTataKelolaKeuanganDesa(rawID string) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	if _, err := s.subDimensionRepo.FindTataKelolaKeuanganDesaByID(id); err != nil {
		return errors.New("record not found")
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.DeleteTataKelolaKeuanganDesaByID(tx, id); err != nil {
		return errors.New("failed to delete")
	}
	return tx.Commit().Error
}

// ── PUT (update) ──────────────────────────────────────────────────────────────

func (s *SubDimensionService) UpdatePendidikan(rawID string, req *dtos.AddSubDimensionPendidikanRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindPendidikanByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.KetersediaanPaud = req.KetersediaanPaud
	rec.KemudahanAksesPaud = req.KemudahanAksesPaud
	rec.ApmPaud = req.ApmPaud
	rec.KemudahanAksesSd = req.KemudahanAksesSd
	rec.ApmSd = req.ApmSd
	rec.KemudahanAksesSmp = req.KemudahanAksesSmp
	rec.ApmSmp = req.ApmSmp
	rec.KemudahanAksesSma = req.KemudahanAksesSma
	rec.ApmSma = req.ApmSma
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdatePendidikanWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateKesehatan(rawID string, req *dtos.AddSubDimensionKesehatanRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindKesehatanByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.KemudahanAksesSaranaKesehatan = req.KemudahanAksesSaranaKesehatan
	rec.KetersediaanFasilitasKesehatan = req.KetersediaanFasilitasKesehatan
	rec.KemudahanAksesFasilitasKesehatan = req.KemudahanAksesFasilitasKesehatan
	rec.KetersediaanPosyandu = req.KetersediaanPosyandu
	rec.JumlahAktivitasPosyandu = req.JumlahAktivitasPosyandu
	rec.KemudahanAksesPosyandu = req.KemudahanAksesPosyandu
	rec.KetersediaanLayananDokter = req.KetersediaanLayananDokter
	rec.HariOperasionalLayananDokter = req.HariOperasionalLayananDokter
	rec.PenyediaLayananDokter = req.PenyediaLayananDokter
	rec.PenyediaTransportasiLayananDokter = req.PenyediaTransportasiLayananDokter
	rec.KetersediaanLayananBidan = req.KetersediaanLayananBidan
	rec.HariOperasionalLayananBidan = req.HariOperasionalLayananBidan
	rec.PenyediaLayananBidan = req.PenyediaLayananBidan
	rec.PenyediaTransportasiLayananBidan = req.PenyediaTransportasiLayananBidan
	rec.KetersediaanLayananTenagaKesehatan = req.KetersediaanLayananTenagaKesehatan
	rec.HariOperasionalLayananTenagaKesehatan = req.HariOperasionalLayananTenagaKesehatan
	rec.PenyediaLayananTenagaKesehatan = req.PenyediaLayananTenagaKesehatan
	rec.PenyediaTransportasiLayananTenagaKesehatan = req.PenyediaTransportasiLayananTenagaKesehatan
	rec.PersentasePesertaJaminanKesehatan = req.PersentasePesertaJaminanKesehatan
	rec.KegiatanSosialisasiJaminanKesehatan = req.KegiatanSosialisasiJaminanKesehatan
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateKesehatanWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateUtilitasDasar(rawID string, req *dtos.AddSubDimensionUtilitasDasarRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindUtilitasDasarByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.OperasionalAirMinum = req.OperasionalAirMinum
	rec.KetersediaanAirMinum = req.KetersediaanAirMinum
	rec.KemudahanAksesAirMinum = req.KemudahanAksesAirMinum
	rec.KualitasAirMinum = req.KualitasAirMinum
	rec.PersentaseRumahTidakLayakHuni = req.PersentaseRumahTidakLayakHuni
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateUtilitasDasarWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateAktivitas(rawID string, req *dtos.AddSubDimensionAktivitasRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindAktivitasByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.KearifanBudayaSosial = req.KearifanBudayaSosial
	rec.KearifanBudayaSosialDipertahankan = req.KearifanBudayaSosialDipertahankan
	rec.KegiatanGotongRoyong = req.KegiatanGotongRoyong
	rec.FrekuensiGotongRoyong = req.FrekuensiGotongRoyong
	rec.KeterlibatanWargaGotongRoyong = req.KeterlibatanWargaGotongRoyong
	rec.FrekuensiKegiatanOlahraga = req.FrekuensiKegiatanOlahraga
	rec.PenyelesaianKonflikSecaraDamai = req.PenyelesaianKonflikSecaraDamai
	rec.PeranAparatKeamananMediator = req.PeranAparatKeamananMediator
	rec.PeranAparatPemerintah = req.PeranAparatPemerintah
	rec.PeranTokohMasyarakat = req.PeranTokohMasyarakat
	rec.PeranTokohAgama = req.PeranTokohAgama
	rec.SatuanKeamananLingkungan = req.SatuanKeamananLingkungan
	rec.AktivitasSatuanKeamananLingkungan = req.AktivitasSatuanKeamananLingkungan
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateAktivitasWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateFasilitasMasyarakat(rawID string, req *dtos.AddSubDimensionFasilitasMasyarakatRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindFasilitasMasyarakatByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.TerdapatTamanBacaanMasyarakat = req.TerdapatTamanBacaanMasyarakat
	rec.HariOperasionalTamanBacaanMasyarakat = req.HariOperasionalTamanBacaanMasyarakat
	rec.KetersediaanFasilitasOlahraga = req.KetersediaanFasilitasOlahraga
	rec.KeberadaanRuangPublikTerbuka = req.KeberadaanRuangPublikTerbuka
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateFasilitasMasyarakatWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateProduksiDesa(rawID string, req *dtos.AddSubDimensionProduksiDesaRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindProduksiDesaByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.KeragamanAktivitasEkonomi = req.KeragamanAktivitasEkonomi
	rec.KeaktifanAktivitasEkonomi = req.KeaktifanAktivitasEkonomi
	rec.KetersediaanProdukUnggulanDesa = req.KetersediaanProdukUnggulanDesa
	rec.CakupanPasarProdukUnggulan = req.CakupanPasarProdukUnggulan
	rec.KetersediaanMerekDagang = req.KetersediaanMerekDagang
	rec.TerdapatKearifanLokalEkonomi = req.TerdapatKearifanLokalEkonomi
	rec.TelahDilakukanKerjaSamaDenganDesaLainnya = req.TelahDilakukanKerjaSamaDenganDesaLainnya
	rec.TelahDilakukanKerjaSamaDenganPihakKetiga = req.TelahDilakukanKerjaSamaDenganPihakKetiga
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateProduksiDesaWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateFasilitasPendukungEkonomi(rawID string, req *dtos.AddSubDimensionFasilitasPendukungEkonomiRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindFasilitasPendukungEkonomiByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.KetersediaanPendidikanNonFormal = req.KetersediaanPendidikanNonFormal
	rec.KeterlibatanPendidikanNonFormal = req.KeterlibatanPendidikanNonFormal
	rec.KetersediaanPasarRakyat = req.KetersediaanPasarRakyat
	rec.KemudahanAksesPasarRakyat = req.KemudahanAksesPasarRakyat
	rec.KetersediaanToko = req.KetersediaanToko
	rec.KemudahanAksesToko = req.KemudahanAksesToko
	rec.KetersediaanRumahMakan = req.KetersediaanRumahMakan
	rec.KemudahanAksesRumahMakan = req.KemudahanAksesRumahMakan
	rec.KetersediaanPenginapan = req.KetersediaanPenginapan
	rec.KemudahanAksesPenginapan = req.KemudahanAksesPenginapan
	rec.KetersediaanLogistik = req.KetersediaanLogistik
	rec.KemudahanAksesLogistik = req.KemudahanAksesLogistik
	rec.TerdapatBumd = req.TerdapatBumd
	rec.BumdBerbadanHukum = req.BumdBerbadanHukum
	rec.HariOperasionalLembagaEkonomi = req.HariOperasionalLembagaEkonomi
	rec.KetersediaanLembagaEkonomiLainnya = req.KetersediaanLembagaEkonomiLainnya
	rec.KetersediaanKud = req.KetersediaanKud
	rec.KetersediaanUmkm = req.KetersediaanUmkm
	rec.LayananPerbankan = req.LayananPerbankan
	rec.HariOperasionalKeuangan = req.HariOperasionalKeuangan
	rec.LayananFasilitasKreditKur = req.LayananFasilitasKreditKur
	rec.LayananFasilitasKreditKkpE = req.LayananFasilitasKreditKkpE
	rec.LayananFasilitasKreditKuk = req.LayananFasilitasKreditKuk
	rec.StatusLayananFasilitasKredit = req.StatusLayananFasilitasKredit
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateFasilitasPendukungEkonomiWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdatePengelolaanLingkungan(rawID string, req *dtos.AddSubDimensionPengelolaanLingkunganRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindPengelolaanLingkunganByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.UpayaMenjagaKelestarianLingkungan = req.UpayaMenjagaKelestarianLingkungan
	rec.RegulasiPelestarianLingkungan = req.RegulasiPelestarianLingkungan
	rec.KegiatanPelestarianLingkungan = req.KegiatanPelestarianLingkungan
	rec.PemanfaatanEnergiTerbarukan = req.PemanfaatanEnergiTerbarukan
	rec.TempatPembuananganSampah = req.TempatPembuananganSampah
	rec.PengelolaanSampah = req.PengelolaanSampah
	rec.PemanfaatanSampah = req.PemanfaatanSampah
	rec.KejadianPencemaranLingkungan = req.KejadianPencemaranLingkungan
	rec.KetersediaanJamban = req.KetersediaanJamban
	rec.KeberfungsianJamban = req.KeberfungsianJamban
	rec.KetersediaanSepticTank = req.KetersediaanSepticTank
	rec.PembuanganAirLimbahCairRumah = req.PembuanganAirLimbahCairRumah
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdatePengelolaanLingkunganWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdatePenanggulanganBencana(rawID string, req *dtos.AddSubDimensionPenanggulanganBencanaRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindPenanggulanganBencanaByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.AspekInformasiKebencanaan = req.AspekInformasiKebencanaan
	rec.FasilitasMitigasiBencana = req.FasilitasMitigasiBencana
	rec.AksesMenujuFasilitasMitigasiBencana = req.AksesMenujuFasilitasMitigasiBencana
	rec.AktivitasMitigasi = req.AktivitasMitigasi
	rec.FasilitasTanggapDaruratBencana = req.FasilitasTanggapDaruratBencana
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdatePenanggulanganBencanaWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateKondisiAksesJalan(rawID string, req *dtos.AddSubDimensionKondisiAksesJalanRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindKondisiAksesJalanByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.JenisPermukaanJalan = req.JenisPermukaanJalan
	rec.KualitasJalan = req.KualitasJalan
	rec.PeneranganJalanUtama = req.PeneranganJalanUtama
	rec.OperasionalPju = req.OperasionalPju
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateKondisiAksesJalanWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateKemudahanAkses(rawID string, req *dtos.AddSubDimensionKemudahanAksesRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindKemudahanAksesByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.AngkutanPerdesaan = req.AngkutanPerdesaan
	rec.OperasionalAngkutanPerdesaan = req.OperasionalAngkutanPerdesaan
	rec.PelayananListrik = req.PelayananListrik
	rec.DurasiLayananListrik = req.DurasiLayananListrik
	rec.AksesTelepon = req.AksesTelepon
	rec.AksesInternet = req.AksesInternet
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateKemudahanAksesWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateKelembagaanPelayananDesa(rawID string, req *dtos.AddSubDimensionKelembagaanPelayananDesaRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindKelembagaanPelayananDesaByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.LayananDiberikan = req.LayananDiberikan
	rec.PublikasiInformasiPelayanan = req.PublikasiInformasiPelayanan
	rec.PelayananAdministrasi = req.PelayananAdministrasi
	rec.PelayananPengaduan = req.PelayananPengaduan
	rec.PelayananLainnya = req.PelayananLainnya
	rec.MusyawarahDesa = req.MusyawarahDesa
	rec.MusyawarahDesaDidatangiUnsurMasyarakat = req.MusyawarahDesaDidatangiUnsurMasyarakat
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateKelembagaanPelayananDesaWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}

func (s *SubDimensionService) UpdateTataKelolaKeuanganDesa(rawID string, req *dtos.AddSubDimensionTataKelolaKeuanganDesaRequest) error {
	id, err := parseID(rawID)
	if err != nil {
		return err
	}
	rec, err := s.subDimensionRepo.FindTataKelolaKeuanganDesaByID(id)
	if err != nil {
		return errors.New("record not found")
	}
	rec.PendapatanAsliDesa = req.PendapatanAsliDesa
	rec.PeningkatanPades = req.PeningkatanPades
	rec.PenyertaanModalDdBumd = req.PenyertaanModalDdBumd
	rec.AsetTanahDesa = req.AsetTanahDesa
	rec.AsetKantorDesa = req.AsetKantorDesa
	rec.AsetPasarDesa = req.AsetPasarDesa
	rec.AsetLainnya = req.AsetLainnya
	rec.ProduktivitasAsetDesa = req.ProduktivitasAsetDesa
	rec.InventarisasiAsetDesa = req.InventarisasiAsetDesa
	if req.Year != nil {
		rec.Year = *req.Year
	}
	tx := s.subDimensionRepo.BeginTransaction()
	defer tx.Rollback()
	if err := s.subDimensionRepo.UpdateTataKelolaKeuanganDesaWithTx(tx, rec); err != nil {
		return errors.New("failed to update")
	}
	return tx.Commit().Error
}
