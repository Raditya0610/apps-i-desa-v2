package repositories

import (
	"Apps-I_Desa_Backend/config"
	"Apps-I_Desa_Backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SubDimensionRepository struct {
	DB *gorm.DB
}

func NewSubDimensionRepository() *SubDimensionRepository {
	return &SubDimensionRepository{
		DB: config.DB,
	}
}

func (r *SubDimensionRepository) BeginTransaction() *gorm.DB {
	return r.DB.Begin()
}

func (r *SubDimensionRepository) CreateSubDimensionPendidikanWithTx(
	tx *gorm.DB,
	pendidikan *models.SubDimensiPendidikan,
) error {
	return tx.Create(pendidikan).Error
}

func (r *SubDimensionRepository) CreateSubDimensionKesehatanWithTx(
	tx *gorm.DB,
	kesehatan *models.SubDimensiKesehatan,
) error {
	return tx.Create(kesehatan).Error
}

func (r *SubDimensionRepository) CreateSubDimensionUtilitasDasarWithTx(
	tx *gorm.DB,
	utilitas *models.SubDimensiUtilitasDasar,
) error {
	return tx.Create(utilitas).Error
}

func (r *SubDimensionRepository) CreateSubDimensionAktivitasWithTx(
	tx *gorm.DB,
	aktivitas *models.SubDimensiAktivitas,
) error {
	return tx.Create(aktivitas).Error
}

func (r *SubDimensionRepository) CreateSubDimensionFasilitasMasyarakatWithTx(
	tx *gorm.DB,
	fasilitas *models.SubDimensiFasilitasMasyarakat,
) error {
	return tx.Create(fasilitas).Error
}

func (r *SubDimensionRepository) CreateSubDimensionProduksiDesaWithTx(
	tx *gorm.DB,
	produksi *models.SubDimensiProduksiDesa,
) error {
	return tx.Create(produksi).Error
}

func (r *SubDimensionRepository) CreateSubDimensionFasilitasPendukungEkonomiWithTx(
	tx *gorm.DB,
	fasilitas *models.SubDimensiFasilitasPendukungEkonomi,
) error {
	return tx.Create(fasilitas).Error
}

func (r *SubDimensionRepository) CreateSubDimensionPengelolaanLingkunganWithTx(
	tx *gorm.DB,
	lingkungan *models.SubDimensiPengelolaanLingkungan,
) error {
	return tx.Create(lingkungan).Error
}

func (r *SubDimensionRepository) CreateSubDimensionPenanggulanganBencanaWithTx(
	tx *gorm.DB,
	bencana *models.SubDimensiPenanggulanganBencana,
) error {
	return tx.Create(bencana).Error
}

func (r *SubDimensionRepository) CreateSubDimensionKondisiAksesJalanWithTx(
	tx *gorm.DB,
	jalan *models.SubDimensiKondisiAksesJalan,
) error {
	return tx.Create(jalan).Error
}

func (r *SubDimensionRepository) CreateSubDimensionKemudahanAksesWithTx(
	tx *gorm.DB,
	akses *models.SubDimensiKemudahanAkses,
) error {
	return tx.Create(akses).Error
}

func (r *SubDimensionRepository) CreateSubDimensionKelembagaanPelayananDesaWithTx(
	tx *gorm.DB,
	kelembagaan *models.SubDimensiKelembagaanPelayananDesa,
) error {
	return tx.Create(kelembagaan).Error
}

func (r *SubDimensionRepository) CreateSubDimensionTataKelolaKeuanganDesaWithTx(
	tx *gorm.DB,
	keuangan *models.SubDimensiTataKelolaKeuanganDesa,
) error {
	return tx.Create(keuangan).Error
}

// ── GET latest by village (for IDM scoring) ───────────────────────────────────

func (r *SubDimensionRepository) GetLatestPendidikanByVillage(villageID uuid.UUID) (*models.SubDimensiPendidikan, error) {
	var rec models.SubDimensiPendidikan
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestKesehatanByVillage(villageID uuid.UUID) (*models.SubDimensiKesehatan, error) {
	var rec models.SubDimensiKesehatan
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestUtilitasDasarByVillage(villageID uuid.UUID) (*models.SubDimensiUtilitasDasar, error) {
	var rec models.SubDimensiUtilitasDasar
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestAktivitasByVillage(villageID uuid.UUID) (*models.SubDimensiAktivitas, error) {
	var rec models.SubDimensiAktivitas
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestFasilitasMasyarakatByVillage(villageID uuid.UUID) (*models.SubDimensiFasilitasMasyarakat, error) {
	var rec models.SubDimensiFasilitasMasyarakat
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestProduksiDesaByVillage(villageID uuid.UUID) (*models.SubDimensiProduksiDesa, error) {
	var rec models.SubDimensiProduksiDesa
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestFasilitasPendukungEkonomiByVillage(villageID uuid.UUID) (*models.SubDimensiFasilitasPendukungEkonomi, error) {
	var rec models.SubDimensiFasilitasPendukungEkonomi
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestPengelolaanLingkunganByVillage(villageID uuid.UUID) (*models.SubDimensiPengelolaanLingkungan, error) {
	var rec models.SubDimensiPengelolaanLingkungan
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestPenanggulanganBencanaByVillage(villageID uuid.UUID) (*models.SubDimensiPenanggulanganBencana, error) {
	var rec models.SubDimensiPenanggulanganBencana
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestKondisiAksesJalanByVillage(villageID uuid.UUID) (*models.SubDimensiKondisiAksesJalan, error) {
	var rec models.SubDimensiKondisiAksesJalan
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestKemudahanAksesByVillage(villageID uuid.UUID) (*models.SubDimensiKemudahanAkses, error) {
	var rec models.SubDimensiKemudahanAkses
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestKelembagaanPelayananDesaByVillage(villageID uuid.UUID) (*models.SubDimensiKelembagaanPelayananDesa, error) {
	var rec models.SubDimensiKelembagaanPelayananDesa
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

func (r *SubDimensionRepository) GetLatestTataKelolaKeuanganDesaByVillage(villageID uuid.UUID) (*models.SubDimensiTataKelolaKeuanganDesa, error) {
	var rec models.SubDimensiTataKelolaKeuanganDesa
	err := r.DB.Where("village_id = ?", villageID).Order("year desc").First(&rec).Error
	return &rec, err
}

// ── GET by village ────────────────────────────────────────────────────────────

func (r *SubDimensionRepository) GetAllPendidikanByVillage(villageID uuid.UUID) ([]*models.SubDimensiPendidikan, error) {
	var records []*models.SubDimensiPendidikan
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllKesehatanByVillage(villageID uuid.UUID) ([]*models.SubDimensiKesehatan, error) {
	var records []*models.SubDimensiKesehatan
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllUtilitasDasarByVillage(villageID uuid.UUID) ([]*models.SubDimensiUtilitasDasar, error) {
	var records []*models.SubDimensiUtilitasDasar
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllAktivitasByVillage(villageID uuid.UUID) ([]*models.SubDimensiAktivitas, error) {
	var records []*models.SubDimensiAktivitas
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllFasilitasMasyarakatByVillage(villageID uuid.UUID) ([]*models.SubDimensiFasilitasMasyarakat, error) {
	var records []*models.SubDimensiFasilitasMasyarakat
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllProduksiDesaByVillage(villageID uuid.UUID) ([]*models.SubDimensiProduksiDesa, error) {
	var records []*models.SubDimensiProduksiDesa
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllFasilitasPendukungEkonomiByVillage(villageID uuid.UUID) ([]*models.SubDimensiFasilitasPendukungEkonomi, error) {
	var records []*models.SubDimensiFasilitasPendukungEkonomi
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllPengelolaanLingkunganByVillage(villageID uuid.UUID) ([]*models.SubDimensiPengelolaanLingkungan, error) {
	var records []*models.SubDimensiPengelolaanLingkungan
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllPenanggulanganBencanaByVillage(villageID uuid.UUID) ([]*models.SubDimensiPenanggulanganBencana, error) {
	var records []*models.SubDimensiPenanggulanganBencana
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllKondisiAksesJalanByVillage(villageID uuid.UUID) ([]*models.SubDimensiKondisiAksesJalan, error) {
	var records []*models.SubDimensiKondisiAksesJalan
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllKemudahanAksesByVillage(villageID uuid.UUID) ([]*models.SubDimensiKemudahanAkses, error) {
	var records []*models.SubDimensiKemudahanAkses
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllKelembagaanPelayananDesaByVillage(villageID uuid.UUID) ([]*models.SubDimensiKelembagaanPelayananDesa, error) {
	var records []*models.SubDimensiKelembagaanPelayananDesa
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

func (r *SubDimensionRepository) GetAllTataKelolaKeuanganDesaByVillage(villageID uuid.UUID) ([]*models.SubDimensiTataKelolaKeuanganDesa, error) {
	var records []*models.SubDimensiTataKelolaKeuanganDesa
	return records, r.DB.Where("village_id = ?", villageID).Order("year desc").Find(&records).Error
}

// ── Find by ID ────────────────────────────────────────────────────────────────

func (r *SubDimensionRepository) FindPendidikanByID(id uuid.UUID) (*models.SubDimensiPendidikan, error) {
	var rec models.SubDimensiPendidikan
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindKesehatanByID(id uuid.UUID) (*models.SubDimensiKesehatan, error) {
	var rec models.SubDimensiKesehatan
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindUtilitasDasarByID(id uuid.UUID) (*models.SubDimensiUtilitasDasar, error) {
	var rec models.SubDimensiUtilitasDasar
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindAktivitasByID(id uuid.UUID) (*models.SubDimensiAktivitas, error) {
	var rec models.SubDimensiAktivitas
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindFasilitasMasyarakatByID(id uuid.UUID) (*models.SubDimensiFasilitasMasyarakat, error) {
	var rec models.SubDimensiFasilitasMasyarakat
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindProduksiDesaByID(id uuid.UUID) (*models.SubDimensiProduksiDesa, error) {
	var rec models.SubDimensiProduksiDesa
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindFasilitasPendukungEkonomiByID(id uuid.UUID) (*models.SubDimensiFasilitasPendukungEkonomi, error) {
	var rec models.SubDimensiFasilitasPendukungEkonomi
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindPengelolaanLingkunganByID(id uuid.UUID) (*models.SubDimensiPengelolaanLingkungan, error) {
	var rec models.SubDimensiPengelolaanLingkungan
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindPenanggulanganBencanaByID(id uuid.UUID) (*models.SubDimensiPenanggulanganBencana, error) {
	var rec models.SubDimensiPenanggulanganBencana
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindKondisiAksesJalanByID(id uuid.UUID) (*models.SubDimensiKondisiAksesJalan, error) {
	var rec models.SubDimensiKondisiAksesJalan
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindKemudahanAksesByID(id uuid.UUID) (*models.SubDimensiKemudahanAkses, error) {
	var rec models.SubDimensiKemudahanAkses
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindKelembagaanPelayananDesaByID(id uuid.UUID) (*models.SubDimensiKelembagaanPelayananDesa, error) {
	var rec models.SubDimensiKelembagaanPelayananDesa
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

func (r *SubDimensionRepository) FindTataKelolaKeuanganDesaByID(id uuid.UUID) (*models.SubDimensiTataKelolaKeuanganDesa, error) {
	var rec models.SubDimensiTataKelolaKeuanganDesa
	return &rec, r.DB.First(&rec, "id = ?", id).Error
}

// ── Update ────────────────────────────────────────────────────────────────────

func (r *SubDimensionRepository) UpdatePendidikanWithTx(tx *gorm.DB, rec *models.SubDimensiPendidikan) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateKesehatanWithTx(tx *gorm.DB, rec *models.SubDimensiKesehatan) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateUtilitasDasarWithTx(tx *gorm.DB, rec *models.SubDimensiUtilitasDasar) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateAktivitasWithTx(tx *gorm.DB, rec *models.SubDimensiAktivitas) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateFasilitasMasyarakatWithTx(tx *gorm.DB, rec *models.SubDimensiFasilitasMasyarakat) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateProduksiDesaWithTx(tx *gorm.DB, rec *models.SubDimensiProduksiDesa) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateFasilitasPendukungEkonomiWithTx(tx *gorm.DB, rec *models.SubDimensiFasilitasPendukungEkonomi) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdatePengelolaanLingkunganWithTx(tx *gorm.DB, rec *models.SubDimensiPengelolaanLingkungan) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdatePenanggulanganBencanaWithTx(tx *gorm.DB, rec *models.SubDimensiPenanggulanganBencana) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateKondisiAksesJalanWithTx(tx *gorm.DB, rec *models.SubDimensiKondisiAksesJalan) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateKemudahanAksesWithTx(tx *gorm.DB, rec *models.SubDimensiKemudahanAkses) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateKelembagaanPelayananDesaWithTx(tx *gorm.DB, rec *models.SubDimensiKelembagaanPelayananDesa) error {
	return tx.Save(rec).Error
}
func (r *SubDimensionRepository) UpdateTataKelolaKeuanganDesaWithTx(tx *gorm.DB, rec *models.SubDimensiTataKelolaKeuanganDesa) error {
	return tx.Save(rec).Error
}

// ── Delete ────────────────────────────────────────────────────────────────────

func (r *SubDimensionRepository) DeletePendidikanByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiPendidikan{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteKesehatanByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiKesehatan{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteUtilitasDasarByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiUtilitasDasar{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteAktivitasByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiAktivitas{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteFasilitasMasyarakatByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiFasilitasMasyarakat{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteProduksiDesaByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiProduksiDesa{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteFasilitasPendukungEkonomiByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiFasilitasPendukungEkonomi{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeletePengelolaanLingkunganByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiPengelolaanLingkungan{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeletePenanggulanganBencanaByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiPenanggulanganBencana{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteKondisiAksesJalanByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiKondisiAksesJalan{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteKemudahanAksesByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiKemudahanAkses{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteKelembagaanPelayananDesaByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiKelembagaanPelayananDesa{}, "id = ?", id).Error
}
func (r *SubDimensionRepository) DeleteTataKelolaKeuanganDesaByID(tx *gorm.DB, id uuid.UUID) error {
	return tx.Delete(&models.SubDimensiTataKelolaKeuanganDesa{}, "id = ?", id).Error
}
