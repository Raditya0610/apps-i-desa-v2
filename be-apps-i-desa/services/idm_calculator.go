package services

import (
	"strconv"
	"strings"

	"Apps-I_Desa_Backend/models"
)

// ── Indeks Desa 2024 (Permendesa PDTT No. 9/2024) scoring ──────────────────────
//
// The official Buku Panduan Indeks Desa 2024 gives an integer "Klasifikasi 1..N"
// table for almost every indicator, but does not publish (a) the formula behind
// the recurring "Kemudahan Akses" composite (jarak + waktu tempuh + ketersediaan
// transportasi -> 1..5), nor (b) a per-indicator weight table that sums to the
// official ceiling per sub-dimension (45 for Pendidikan, 100 for Kesehatan, ...).
// Replicating the official rubric field-for-field would require collecting raw
// data (distance in km, time in minutes, unit counts) that the existing forms
// never asked for — a form/schema rewrite far beyond "fix the aggregation".
//
// Instead, every existing option field (already an ordered list, best -> worst,
// same lists driving the Flutter dropdowns in core/constants/form_options.dart)
// is scored as len(options)-index — an integer, "first option = best = highest
// score". These per-field integer scores are summed per sub-dimension, then
// proportionally rescaled to that sub-dimension's official ceiling:
//
//	subDimensionPoints = round(achieved / max * officialCeiling)
//
// This keeps every official ceiling/total (635) and status threshold exact,
// while being honest that the internal per-field granularity is coarser than
// the unpublished official rubric.

// Option lists matching form_options.dart order (first=best, last=worst unless noted)
var (
	optKetersediaan        = []string{"Tersedia", "Tidak Tersedia"}
	optKemudahanAkses      = []string{"Mudah", "Sedang", "Sulit"}
	optKeberadaan          = []string{"Ada", "Tidak Ada"}
	optFrekuensi           = []string{"Rutin", "Kadang-kadang", "Tidak Ada"}
	optTingkat             = []string{"Tinggi", "Sedang", "Rendah"}
	optKualitas            = []string{"Baik", "Cukup", "Buruk"}
	optKeberfungsian       = []string{"Berfungsi", "Tidak Berfungsi"}
	optYaTidak             = []string{"Ya", "Tidak"}
	optHariOperasional     = []string{"Setiap Hari", "Tertentu", "Tidak Ada"}
	optDipertahankan       = []string{"Dipertahankan", "Tidak Dipertahankan"}
	optKeragaman           = []string{"Beragam", "Tidak Beragam"}
	optKeaktifan           = []string{"Aktif", "Cukup Aktif", "Kurang Aktif"}
	optKelengkapan         = []string{"Lengkap", "Cukup", "Kurang"}
	optOperasionalAngkutan = []string{"Setiap Hari", "Tertentu", "Tidak Ada"}
	optDurasiLayanan       = []string{"24 Jam", "Tertentu", "Tidak Ada"}
	optPeningkatan         = []string{"Meningkat", "Stabil", "Menurun"}
	optStatus              = []string{"Aktif", "Tidak Aktif"}
)

// Official per-sub-dimension ceilings — sum to 635. Sourced directly from the
// user's "Uji Petik Simulasi Skor dan Status Indeks Desa 2025" reference sheet.
var subDimensionCeiling = map[string]int{
	"pendidikan":                  45,
	"kesehatan":                   100,
	"utilitas_dasar":              25,
	"aktivitas":                   65,
	"fasilitas_masyarakat":        20,
	"produksi_desa":               40,
	"fasilitas_pendukung_ekonomi": 120,
	"pengelolaan_lingkungan":      65,
	"penanggulangan_bencana":      25,
	"kondisi_akses_jalan":         20,
	"kemudahan_akses":             30,
	"kelembagaan_pelayanan_desa":  35,
	"tata_kelola_keuangan_desa":   45,
}

// Official 6-dimension grouping of the 13 sub-dimensions.
var dimensionSubDimensions = map[string][]string{
	"layanan_dasar": {"pendidikan", "kesehatan", "utilitas_dasar"},
	"sosial":        {"aktivitas", "fasilitas_masyarakat"},
	"ekonomi":       {"produksi_desa", "fasilitas_pendukung_ekonomi"},
	"lingkungan":    {"pengelolaan_lingkungan", "penanggulangan_bencana"},
	"aksesibilitas": {"kondisi_akses_jalan", "kemudahan_akses"},
	"tata_kelola":   {"kelembagaan_pelayanan_desa", "tata_kelola_keuangan_desa"},
}

// scorePair bundles one indicator's achieved score with its max — the unit
// every scoreX function accumulates before proportional rescaling.
type scorePair struct{ score, max int }

func pair(score, max int) scorePair { return scorePair{score, max} }

// sumPairs folds a sub-dimension's individual indicator pairs into one total.
func sumPairs(pairs ...scorePair) (achieved, max int) {
	for _, p := range pairs {
		achieved += p.score
		max += p.max
	}
	return
}

// scaleToOfficial converts a raw achieved/max pair into the official 0..ceiling
// point scale for one sub-dimension. See the file-level doc comment for why
// this proportional rescale exists instead of an unpublished official
// per-indicator weight table.
func scaleToOfficial(achieved, max, ceiling int) int {
	if max == 0 {
		return 0
	}
	return int(float64(achieved)/float64(max)*float64(ceiling) + 0.5)
}

// idStatus maps an Indeks Desa percentage (0-100) to the official village
// status label (Permendesa PDTT No. 9/2024).
func idStatus(percentage float64) string {
	switch {
	case percentage > 79.62:
		return "Desa Mandiri"
	case percentage > 69.34:
		return "Desa Maju"
	case percentage > 57.38:
		return "Desa Berkembang"
	case percentage > 49.48:
		return "Desa Tertinggal"
	default:
		return "Desa Sangat Tertinggal"
	}
}

// scoreLinear maps an option's position to an integer score: the first option
// (best) scores len(options), the last (worst) scores 1. An unrecognized value
// scores 0 but still counts len(options) toward max, so the denominator stays
// stable regardless of data quality.
func scoreLinear(value string, options []string) (score, max int) {
	max = len(options)
	if max == 0 {
		return 0, 0
	}
	trimmed := strings.TrimSpace(value)
	for i, opt := range options {
		if strings.EqualFold(trimmed, strings.TrimSpace(opt)) {
			return max - i, max
		}
	}
	return 0, max
}

// scorePercentage maps a "0-100" string onto an integer 0-5 scale.
func scorePercentage(value string) (score, max int) {
	max = 5
	val, err := strconv.ParseFloat(strings.TrimSpace(value), 64)
	if err != nil || val <= 0 {
		return 0, max
	}
	if val >= 100 {
		return max, max
	}
	return int(val/100*float64(max) + 0.5), max
}

// scorePercentageInverse is scorePercentage with the scale flipped — for
// indicators where a higher percentage is worse (e.g. rumah tidak layak huni).
func scorePercentageInverse(value string) (score, max int) {
	s, m := scorePercentage(value)
	return m - s, m
}

// nonEmpty scores 1 if the string has content, 0 otherwise.
func nonEmpty(value string) (score, max int) {
	max = 1
	if strings.TrimSpace(value) != "" {
		return 1, max
	}
	return 0, max
}

// scorePosyanduCount scores the number of posyandu activities per year.
func scorePosyanduCount(value string) (score, max int) {
	max = 3
	val, err := strconv.Atoi(strings.TrimSpace(value))
	if err != nil || val <= 0 {
		return 0, max
	}
	if val >= 8 {
		return 3, max
	}
	if val >= 4 {
		return 2, max
	}
	return 1, max
}

// Special scorers for non-linear options.

func scoreJenisPermukaan(value string) (score, max int) {
	max = 4
	switch strings.TrimSpace(value) {
	case "Aspal":
		return 4, max
	case "Beton":
		return 3, max
	case "Kerikil":
		return 2, max
	case "Tanah":
		return 1, max
	}
	return 0, max
}

func scoreOperasionalPju(value string) (score, max int) {
	max = 3
	switch strings.TrimSpace(value) {
	case "Berfungsi":
		return 3, max
	case "Sebagian":
		return 2, max
	case "Tidak Berfungsi":
		return 1, max
	}
	return 0, max
}

func scoreCakupanPasar(value string) (score, max int) {
	max = 4
	switch strings.TrimSpace(value) {
	case "Lokal":
		return 1, max
	case "Regional":
		return 2, max
	case "Nasional":
		return 3, max
	case "Internasional":
		return 4, max
	}
	return 0, max
}

// ── Sub-dimension scorers ─────────────────────────────────────────────────────
// Each returns (achieved, max) — the raw sum of its indicators' integer scores,
// before scaleToOfficial rescales it to the sub-dimension's official ceiling.

func scorePendidikan(r *models.SubDimensiPendidikan) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.KetersediaanPaud, optKetersediaan)),
		pair(scoreLinear(r.KemudahanAksesPaud, optKemudahanAkses)),
		pair(scorePercentage(r.ApmPaud)),
		pair(scoreLinear(r.KemudahanAksesSd, optKemudahanAkses)),
		pair(scorePercentage(r.ApmSd)),
		pair(scoreLinear(r.KemudahanAksesSmp, optKemudahanAkses)),
		pair(scorePercentage(r.ApmSmp)),
		pair(scoreLinear(r.KemudahanAksesSma, optKemudahanAkses)),
		pair(scorePercentage(r.ApmSma)),
	)
}

func scoreKesehatan(r *models.SubDimensiKesehatan) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.KemudahanAksesSaranaKesehatan, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanFasilitasKesehatan, optKetersediaan)),
		pair(scoreLinear(r.KemudahanAksesFasilitasKesehatan, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanPosyandu, optKetersediaan)),
		pair(scorePosyanduCount(r.JumlahAktivitasPosyandu)),
		pair(scoreLinear(r.KemudahanAksesPosyandu, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanLayananDokter, optKetersediaan)),
		pair(scoreLinear(r.HariOperasionalLayananDokter, optHariOperasional)),
		pair(nonEmpty(r.PenyediaLayananDokter)),
		pair(scoreLinear(r.PenyediaTransportasiLayananDokter, optKetersediaan)),
		pair(scoreLinear(r.KetersediaanLayananBidan, optKetersediaan)),
		pair(scoreLinear(r.HariOperasionalLayananBidan, optHariOperasional)),
		pair(nonEmpty(r.PenyediaLayananBidan)),
		pair(scoreLinear(r.PenyediaTransportasiLayananBidan, optKetersediaan)),
		pair(scoreLinear(r.KetersediaanLayananTenagaKesehatan, optKetersediaan)),
		pair(scoreLinear(r.HariOperasionalLayananTenagaKesehatan, optHariOperasional)),
		pair(nonEmpty(r.PenyediaLayananTenagaKesehatan)),
		pair(scoreLinear(r.PenyediaTransportasiLayananTenagaKesehatan, optKetersediaan)),
		pair(scorePercentage(r.PersentasePesertaJaminanKesehatan)),
		pair(scoreLinear(r.KegiatanSosialisasiJaminanKesehatan, optFrekuensi)),
	)
}

func scoreUtilitasDasar(r *models.SubDimensiUtilitasDasar) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.OperasionalAirMinum, optKeberfungsian)),
		pair(scoreLinear(r.KetersediaanAirMinum, optKetersediaan)),
		pair(scoreLinear(r.KemudahanAksesAirMinum, optKemudahanAkses)),
		pair(scoreLinear(r.KualitasAirMinum, optKualitas)),
		// Rumah tidak layak huni: higher % = worse.
		pair(scorePercentageInverse(r.PersentaseRumahTidakLayakHuni)),
	)
}

func scoreAktivitas(r *models.SubDimensiAktivitas) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.KearifanBudayaSosial, optKeberadaan)),
		pair(scoreLinear(r.KearifanBudayaSosialDipertahankan, optDipertahankan)),
		pair(scoreLinear(r.KegiatanGotongRoyong, optKeberadaan)),
		pair(scoreLinear(r.FrekuensiGotongRoyong, optFrekuensi)),
		pair(scoreLinear(r.KeterlibatanWargaGotongRoyong, optTingkat)),
		pair(scoreLinear(r.FrekuensiKegiatanOlahraga, optFrekuensi)),
		pair(scoreLinear(r.PenyelesaianKonflikSecaraDamai, optKeberadaan)),
		pair(scoreLinear(r.PeranAparatKeamananMediator, optKeberadaan)),
		pair(scoreLinear(r.PeranAparatPemerintah, optKeberadaan)),
		pair(scoreLinear(r.PeranTokohMasyarakat, optKeberadaan)),
		pair(scoreLinear(r.PeranTokohAgama, optKeberadaan)),
		pair(scoreLinear(r.SatuanKeamananLingkungan, optKeberadaan)),
		pair(scoreLinear(r.AktivitasSatuanKeamananLingkungan, optStatus)),
	)
}

func scoreFasilitasMasyarakat(r *models.SubDimensiFasilitasMasyarakat) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.TerdapatTamanBacaanMasyarakat, optKeberadaan)),
		pair(scoreLinear(r.HariOperasionalTamanBacaanMasyarakat, optHariOperasional)),
		pair(scoreLinear(r.KetersediaanFasilitasOlahraga, optKetersediaan)),
		pair(scoreLinear(r.KeberadaanRuangPublikTerbuka, optKeberadaan)),
	)
}

func scoreProduksiDesa(r *models.SubDimensiProduksiDesa) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.KeragamanAktivitasEkonomi, optKeragaman)),
		pair(scoreLinear(r.KeaktifanAktivitasEkonomi, optKeaktifan)),
		pair(scoreLinear(r.KetersediaanProdukUnggulanDesa, optKeberadaan)),
		pair(scoreCakupanPasar(r.CakupanPasarProdukUnggulan)),
		pair(scoreLinear(r.KetersediaanMerekDagang, optKeberadaan)),
		pair(scoreLinear(r.TerdapatKearifanLokalEkonomi, optKeberadaan)),
		pair(scoreLinear(r.TelahDilakukanKerjaSamaDenganDesaLainnya, optKeberadaan)),
		pair(scoreLinear(r.TelahDilakukanKerjaSamaDenganPihakKetiga, optKeberadaan)),
	)
}

func scoreFasilitasPendukungEkonomi(r *models.SubDimensiFasilitasPendukungEkonomi) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.KetersediaanPendidikanNonFormal, optKetersediaan)),
		pair(scoreLinear(r.KeterlibatanPendidikanNonFormal, optTingkat)),
		pair(scoreLinear(r.KetersediaanPasarRakyat, optKeberadaan)),
		pair(scoreLinear(r.KemudahanAksesPasarRakyat, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanToko, optKeberadaan)),
		pair(scoreLinear(r.KemudahanAksesToko, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanRumahMakan, optKeberadaan)),
		pair(scoreLinear(r.KemudahanAksesRumahMakan, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanPenginapan, optKeberadaan)),
		pair(scoreLinear(r.KemudahanAksesPenginapan, optKemudahanAkses)),
		pair(scoreLinear(r.KetersediaanLogistik, optKeberadaan)),
		pair(scoreLinear(r.KemudahanAksesLogistik, optKemudahanAkses)),
		pair(scoreLinear(r.TerdapatBumd, optKeberadaan)),
		pair(scoreLinear(r.BumdBerbadanHukum, optYaTidak)),
		pair(scoreLinear(r.HariOperasionalLembagaEkonomi, optHariOperasional)),
		pair(scoreLinear(r.KetersediaanLembagaEkonomiLainnya, optKeberadaan)),
		pair(scoreLinear(r.KetersediaanKud, optKeberadaan)),
		pair(scoreLinear(r.KetersediaanUmkm, optKeberadaan)),
		pair(scoreLinear(r.LayananPerbankan, optKeberadaan)),
		pair(scoreLinear(r.HariOperasionalKeuangan, optHariOperasional)),
		pair(scoreLinear(r.LayananFasilitasKreditKur, optKeberadaan)),
		pair(scoreLinear(r.LayananFasilitasKreditKkpE, optKeberadaan)),
		pair(scoreLinear(r.LayananFasilitasKreditKuk, optKeberadaan)),
		pair(scoreLinear(r.StatusLayananFasilitasKredit, optStatus)),
	)
}

func scorePengelolaanLingkungan(r *models.SubDimensiPengelolaanLingkungan) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.UpayaMenjagaKelestarianLingkungan, optKeberadaan)),
		pair(scoreLinear(r.RegulasiPelestarianLingkungan, optKeberadaan)),
		pair(scoreLinear(r.KegiatanPelestarianLingkungan, optFrekuensi)),
		pair(scoreLinear(r.PemanfaatanEnergiTerbarukan, optKeberadaan)),
		pair(scoreLinear(r.TempatPembuananganSampah, optKeberadaan)),
		pair(scoreLinear(r.PengelolaanSampah, optKualitas)),
		pair(scoreLinear(r.PemanfaatanSampah, optKeberadaan)),
		// Pencemaran: Ada = bad (low score), Tidak Ada = good (high score).
		pair(scoreLinear(r.KejadianPencemaranLingkungan, []string{"Tidak Ada", "Ada"})),
		pair(scoreLinear(r.KetersediaanJamban, optKetersediaan)),
		pair(scoreLinear(r.KeberfungsianJamban, optKeberfungsian)),
		pair(scoreLinear(r.KetersediaanSepticTank, optKetersediaan)),
		pair(scoreLinear(r.PembuanganAirLimbahCairRumah, optKualitas)),
	)
}

func scorePenanggulanganBencana(r *models.SubDimensiPenanggulanganBencana) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.AspekInformasiKebencanaan, optKeberadaan)),
		pair(scoreLinear(r.FasilitasMitigasiBencana, optKeberadaan)),
		pair(scoreLinear(r.AksesMenujuFasilitasMitigasiBencana, optKemudahanAkses)),
		pair(scoreLinear(r.AktivitasMitigasi, optKeberadaan)),
		pair(scoreLinear(r.FasilitasTanggapDaruratBencana, optKeberadaan)),
	)
}

func scoreKondisiAksesJalan(r *models.SubDimensiKondisiAksesJalan) (int, int) {
	return sumPairs(
		pair(scoreJenisPermukaan(r.JenisPermukaanJalan)),
		pair(scoreLinear(r.KualitasJalan, optKualitas)),
		pair(scoreLinear(r.PeneranganJalanUtama, optKeberadaan)),
		pair(scoreOperasionalPju(r.OperasionalPju)),
	)
}

func scoreKemudahanAkses(r *models.SubDimensiKemudahanAkses) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.AngkutanPerdesaan, optKeberadaan)),
		pair(scoreLinear(r.OperasionalAngkutanPerdesaan, optOperasionalAngkutan)),
		pair(scoreLinear(r.PelayananListrik, optKeberadaan)),
		pair(scoreLinear(r.DurasiLayananListrik, optDurasiLayanan)),
		pair(scoreLinear(r.AksesTelepon, optKetersediaan)),
		pair(scoreLinear(r.AksesInternet, optKetersediaan)),
	)
}

func scoreKelembagaanPelayananDesa(r *models.SubDimensiKelembagaanPelayananDesa) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.LayananDiberikan, optKelengkapan)),
		pair(scoreLinear(r.PublikasiInformasiPelayanan, optKeberadaan)),
		pair(scoreLinear(r.PelayananAdministrasi, optKeberadaan)),
		pair(scoreLinear(r.PelayananPengaduan, optKeberadaan)),
		pair(scoreLinear(r.PelayananLainnya, optKeberadaan)),
		pair(scoreLinear(r.MusyawarahDesa, optFrekuensi)),
		pair(scoreLinear(r.MusyawarahDesaDidatangiUnsurMasyarakat, optYaTidak)),
	)
}

func scoreTataKelolaKeuanganDesa(r *models.SubDimensiTataKelolaKeuanganDesa) (int, int) {
	return sumPairs(
		pair(scoreLinear(r.PendapatanAsliDesa, optKeberadaan)),
		pair(scoreLinear(r.PeningkatanPades, optPeningkatan)),
		pair(scoreLinear(r.PenyertaanModalDdBumd, optKeberadaan)),
		pair(scoreLinear(r.AsetTanahDesa, optKeberadaan)),
		pair(scoreLinear(r.AsetKantorDesa, optKeberadaan)),
		pair(scoreLinear(r.AsetPasarDesa, optKeberadaan)),
		pair(scoreLinear(r.AsetLainnya, optKeberadaan)),
		pair(scoreLinear(r.ProduktivitasAsetDesa, optTingkat)),
		pair(scoreLinear(r.InventarisasiAsetDesa, optKelengkapan)),
	)
}
