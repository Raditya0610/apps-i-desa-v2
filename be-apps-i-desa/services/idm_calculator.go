package services

import (
	"strconv"
	"strings"

	"Apps-I_Desa_Backend/models"
)

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

// scoreLinear maps first option → 1.0, last option → 0.0 linearly.
func scoreLinear(value string, options []string) float64 {
	n := len(options)
	if n <= 1 {
		return 0.5
	}
	trimmed := strings.TrimSpace(value)
	for i, opt := range options {
		if strings.EqualFold(trimmed, strings.TrimSpace(opt)) {
			return 1.0 - float64(i)/float64(n-1)
		}
	}
	return 0.0
}

// scorePercentage parses a "0–100" string and normalises to 0–1.
func scorePercentage(value string) float64 {
	val, err := strconv.ParseFloat(strings.TrimSpace(value), 64)
	if err != nil {
		return 0
	}
	if val <= 0 {
		return 0
	}
	if val >= 100 {
		return 1
	}
	return val / 100.0
}

// nonEmpty returns 1 if the string has content, 0 otherwise.
func nonEmpty(value string) float64 {
	if strings.TrimSpace(value) != "" {
		return 1.0
	}
	return 0.0
}

// scorePosyanduCount scores the number of posyandu activities per year.
func scorePosyanduCount(value string) float64 {
	val, err := strconv.Atoi(strings.TrimSpace(value))
	if err != nil {
		return 0
	}
	if val >= 8 {
		return 1.0
	}
	if val >= 4 {
		return 0.5
	}
	if val >= 1 {
		return 0.25
	}
	return 0.0
}

// Special scorers for non-linear options.

func scoreJenisPermukaan(value string) float64 {
	switch strings.TrimSpace(value) {
	case "Aspal":
		return 1.0
	case "Beton":
		return 0.75
	case "Kerikil":
		return 0.5
	case "Tanah":
		return 0.25
	}
	return 0.0
}

func scoreOperasionalPju(value string) float64 {
	switch strings.TrimSpace(value) {
	case "Berfungsi":
		return 1.0
	case "Sebagian":
		return 0.5
	case "Tidak Berfungsi":
		return 0.0
	}
	return 0.0
}

func scoreCakupanPasar(value string) float64 {
	switch strings.TrimSpace(value) {
	case "Lokal":
		return 0.25
	case "Regional":
		return 0.5
	case "Nasional":
		return 0.75
	case "Internasional":
		return 1.0
	}
	return 0.0
}

// avg computes the mean of a set of scores.
func avg(scores ...float64) float64 {
	if len(scores) == 0 {
		return 0
	}
	total := 0.0
	for _, s := range scores {
		total += s
	}
	return total / float64(len(scores))
}

// idmStatus maps an IDM score to the official village status label.
func idmStatus(idm float64) string {
	switch {
	case idm > 0.8155:
		return "Desa Mandiri"
	case idm > 0.7072:
		return "Desa Maju"
	case idm > 0.5989:
		return "Desa Berkembang"
	case idm > 0.4907:
		return "Desa Tertinggal"
	default:
		return "Desa Sangat Tertinggal"
	}
}

// ── Sub-dimension scorers ─────────────────────────────────────────────────────

func scorePendidikan(r *models.SubDimensiPendidikan) float64 {
	return avg(
		scoreLinear(r.KetersediaanPaud, optKetersediaan),
		scoreLinear(r.KemudahanAksesPaud, optKemudahanAkses),
		scorePercentage(r.ApmPaud),
		scoreLinear(r.KemudahanAksesSd, optKemudahanAkses),
		scorePercentage(r.ApmSd),
		scoreLinear(r.KemudahanAksesSmp, optKemudahanAkses),
		scorePercentage(r.ApmSmp),
		scoreLinear(r.KemudahanAksesSma, optKemudahanAkses),
		scorePercentage(r.ApmSma),
	)
}

func scoreKesehatan(r *models.SubDimensiKesehatan) float64 {
	return avg(
		scoreLinear(r.KemudahanAksesSaranaKesehatan, optKemudahanAkses),
		scoreLinear(r.KetersediaanFasilitasKesehatan, optKetersediaan),
		scoreLinear(r.KemudahanAksesFasilitasKesehatan, optKemudahanAkses),
		scoreLinear(r.KetersediaanPosyandu, optKetersediaan),
		scorePosyanduCount(r.JumlahAktivitasPosyandu),
		scoreLinear(r.KemudahanAksesPosyandu, optKemudahanAkses),
		scoreLinear(r.KetersediaanLayananDokter, optKetersediaan),
		scoreLinear(r.HariOperasionalLayananDokter, optHariOperasional),
		nonEmpty(r.PenyediaLayananDokter),
		scoreLinear(r.PenyediaTransportasiLayananDokter, optKetersediaan),
		scoreLinear(r.KetersediaanLayananBidan, optKetersediaan),
		scoreLinear(r.HariOperasionalLayananBidan, optHariOperasional),
		nonEmpty(r.PenyediaLayananBidan),
		scoreLinear(r.PenyediaTransportasiLayananBidan, optKetersediaan),
		scoreLinear(r.KetersediaanLayananTenagaKesehatan, optKetersediaan),
		scoreLinear(r.HariOperasionalLayananTenagaKesehatan, optHariOperasional),
		nonEmpty(r.PenyediaLayananTenagaKesehatan),
		scoreLinear(r.PenyediaTransportasiLayananTenagaKesehatan, optKetersediaan),
		scorePercentage(r.PersentasePesertaJaminanKesehatan),
		scoreLinear(r.KegiatanSosialisasiJaminanKesehatan, optFrekuensi),
	)
}

func scoreUtilitasDasar(r *models.SubDimensiUtilitasDasar) float64 {
	return avg(
		scoreLinear(r.OperasionalAirMinum, optKeberfungsian),
		scoreLinear(r.KetersediaanAirMinum, optKetersediaan),
		scoreLinear(r.KemudahanAksesAirMinum, optKemudahanAkses),
		scoreLinear(r.KualitasAirMinum, optKualitas),
		// Rumah tidak layak huni: higher % = worse
		1.0-scorePercentage(r.PersentaseRumahTidakLayakHuni),
	)
}

func scoreAktivitas(r *models.SubDimensiAktivitas) float64 {
	return avg(
		scoreLinear(r.KearifanBudayaSosial, optKeberadaan),
		scoreLinear(r.KearifanBudayaSosialDipertahankan, optDipertahankan),
		scoreLinear(r.KegiatanGotongRoyong, optKeberadaan),
		scoreLinear(r.FrekuensiGotongRoyong, optFrekuensi),
		scoreLinear(r.KeterlibatanWargaGotongRoyong, optTingkat),
		scoreLinear(r.FrekuensiKegiatanOlahraga, optFrekuensi),
		scoreLinear(r.PenyelesaianKonflikSecaraDamai, optKeberadaan),
		scoreLinear(r.PeranAparatKeamananMediator, optKeberadaan),
		scoreLinear(r.PeranAparatPemerintah, optKeberadaan),
		scoreLinear(r.PeranTokohMasyarakat, optKeberadaan),
		scoreLinear(r.PeranTokohAgama, optKeberadaan),
		scoreLinear(r.SatuanKeamananLingkungan, optKeberadaan),
		scoreLinear(r.AktivitasSatuanKeamananLingkungan, optStatus),
	)
}

func scoreFasilitasMasyarakat(r *models.SubDimensiFasilitasMasyarakat) float64 {
	return avg(
		scoreLinear(r.TerdapatTamanBacaanMasyarakat, optKeberadaan),
		scoreLinear(r.HariOperasionalTamanBacaanMasyarakat, optHariOperasional),
		scoreLinear(r.KetersediaanFasilitasOlahraga, optKetersediaan),
		scoreLinear(r.KeberadaanRuangPublikTerbuka, optKeberadaan),
	)
}

func scoreProduksiDesa(r *models.SubDimensiProduksiDesa) float64 {
	return avg(
		scoreLinear(r.KeragamanAktivitasEkonomi, optKeragaman),
		scoreLinear(r.KeaktifanAktivitasEkonomi, optKeaktifan),
		scoreLinear(r.KetersediaanProdukUnggulanDesa, optKeberadaan),
		scoreCakupanPasar(r.CakupanPasarProdukUnggulan),
		scoreLinear(r.KetersediaanMerekDagang, optKeberadaan),
		scoreLinear(r.TerdapatKearifanLokalEkonomi, optKeberadaan),
		scoreLinear(r.TelahDilakukanKerjaSamaDenganDesaLainnya, optKeberadaan),
		scoreLinear(r.TelahDilakukanKerjaSamaDenganPihakKetiga, optKeberadaan),
	)
}

func scoreFasilitasPendukungEkonomi(r *models.SubDimensiFasilitasPendukungEkonomi) float64 {
	return avg(
		scoreLinear(r.KetersediaanPendidikanNonFormal, optKetersediaan),
		scoreLinear(r.KeterlibatanPendidikanNonFormal, optTingkat),
		scoreLinear(r.KetersediaanPasarRakyat, optKeberadaan),
		scoreLinear(r.KemudahanAksesPasarRakyat, optKemudahanAkses),
		scoreLinear(r.KetersediaanToko, optKeberadaan),
		scoreLinear(r.KemudahanAksesToko, optKemudahanAkses),
		scoreLinear(r.KetersediaanRumahMakan, optKeberadaan),
		scoreLinear(r.KemudahanAksesRumahMakan, optKemudahanAkses),
		scoreLinear(r.KetersediaanPenginapan, optKeberadaan),
		scoreLinear(r.KemudahanAksesPenginapan, optKemudahanAkses),
		scoreLinear(r.KetersediaanLogistik, optKeberadaan),
		scoreLinear(r.KemudahanAksesLogistik, optKemudahanAkses),
		scoreLinear(r.TerdapatBumd, optKeberadaan),
		scoreLinear(r.BumdBerbadanHukum, optYaTidak),
		scoreLinear(r.HariOperasionalLembagaEkonomi, optHariOperasional),
		scoreLinear(r.KetersediaanLembagaEkonomiLainnya, optKeberadaan),
		scoreLinear(r.KetersediaanKud, optKeberadaan),
		scoreLinear(r.KetersediaanUmkm, optKeberadaan),
		scoreLinear(r.LayananPerbankan, optKeberadaan),
		scoreLinear(r.HariOperasionalKeuangan, optHariOperasional),
		scoreLinear(r.LayananFasilitasKreditKur, optKeberadaan),
		scoreLinear(r.LayananFasilitasKreditKkpE, optKeberadaan),
		scoreLinear(r.LayananFasilitasKreditKuk, optKeberadaan),
		scoreLinear(r.StatusLayananFasilitasKredit, optStatus),
	)
}

func scorePengelolaanLingkungan(r *models.SubDimensiPengelolaanLingkungan) float64 {
	return avg(
		scoreLinear(r.UpayaMenjagaKelestarianLingkungan, optKeberadaan),
		scoreLinear(r.RegulasiPelestarianLingkungan, optKeberadaan),
		scoreLinear(r.KegiatanPelestarianLingkungan, optFrekuensi),
		scoreLinear(r.PemanfaatanEnergiTerbarukan, optKeberadaan),
		scoreLinear(r.TempatPembuananganSampah, optKeberadaan),
		scoreLinear(r.PengelolaanSampah, optKualitas),
		scoreLinear(r.PemanfaatanSampah, optKeberadaan),
		// Pencemaran: Ada = bad (0), Tidak Ada = good (1)
		scoreLinear(r.KejadianPencemaranLingkungan, []string{"Tidak Ada", "Ada"}),
		scoreLinear(r.KetersediaanJamban, optKetersediaan),
		scoreLinear(r.KeberfungsianJamban, optKeberfungsian),
		scoreLinear(r.KetersediaanSepticTank, optKetersediaan),
		scoreLinear(r.PembuanganAirLimbahCairRumah, optKualitas),
	)
}

func scorePenanggulanganBencana(r *models.SubDimensiPenanggulanganBencana) float64 {
	return avg(
		scoreLinear(r.AspekInformasiKebencanaan, optKeberadaan),
		scoreLinear(r.FasilitasMitigasiBencana, optKeberadaan),
		scoreLinear(r.AksesMenujuFasilitasMitigasiBencana, optKemudahanAkses),
		scoreLinear(r.AktivitasMitigasi, optKeberadaan),
		scoreLinear(r.FasilitasTanggapDaruratBencana, optKeberadaan),
	)
}

func scoreKondisiAksesJalan(r *models.SubDimensiKondisiAksesJalan) float64 {
	return avg(
		scoreJenisPermukaan(r.JenisPermukaanJalan),
		scoreLinear(r.KualitasJalan, optKualitas),
		scoreLinear(r.PeneranganJalanUtama, optKeberadaan),
		scoreOperasionalPju(r.OperasionalPju),
	)
}

func scoreKemudahanAkses(r *models.SubDimensiKemudahanAkses) float64 {
	return avg(
		scoreLinear(r.AngkutanPerdesaan, optKeberadaan),
		scoreLinear(r.OperasionalAngkutanPerdesaan, optOperasionalAngkutan),
		scoreLinear(r.PelayananListrik, optKeberadaan),
		scoreLinear(r.DurasiLayananListrik, optDurasiLayanan),
		scoreLinear(r.AksesTelepon, optKetersediaan),
		scoreLinear(r.AksesInternet, optKetersediaan),
	)
}

func scoreKelembagaanPelayananDesa(r *models.SubDimensiKelembagaanPelayananDesa) float64 {
	return avg(
		scoreLinear(r.LayananDiberikan, optKelengkapan),
		scoreLinear(r.PublikasiInformasiPelayanan, optKeberadaan),
		scoreLinear(r.PelayananAdministrasi, optKeberadaan),
		scoreLinear(r.PelayananPengaduan, optKeberadaan),
		scoreLinear(r.PelayananLainnya, optKeberadaan),
		scoreLinear(r.MusyawarahDesa, optFrekuensi),
		scoreLinear(r.MusyawarahDesaDidatangiUnsurMasyarakat, optYaTidak),
	)
}

func scoreTataKelolaKeuanganDesa(r *models.SubDimensiTataKelolaKeuanganDesa) float64 {
	return avg(
		scoreLinear(r.PendapatanAsliDesa, optKeberadaan),
		scoreLinear(r.PeningkatanPades, optPeningkatan),
		scoreLinear(r.PenyertaanModalDdBumd, optKeberadaan),
		scoreLinear(r.AsetTanahDesa, optKeberadaan),
		scoreLinear(r.AsetKantorDesa, optKeberadaan),
		scoreLinear(r.AsetPasarDesa, optKeberadaan),
		scoreLinear(r.AsetLainnya, optKeberadaan),
		scoreLinear(r.ProduktivitasAsetDesa, optTingkat),
		scoreLinear(r.InventarisasiAsetDesa, optKelengkapan),
	)
}
