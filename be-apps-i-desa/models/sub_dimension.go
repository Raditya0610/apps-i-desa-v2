package models

import "github.com/google/uuid"

type SubDimensiPendidikan struct {
	ID                 uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID          uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year               int       `gorm:"size:4"                                          json:"year"`
	KetersediaanPaud   string    `gorm:"size:50;not null"                                json:"ketersediaan_paud"`
	KemudahanAksesPaud string    `gorm:"size:50;not null"                                json:"kemudahan_akses_paud"`
	ApmPaud            string    `gorm:"size:50;not null"                                json:"apm_paud"`
	KemudahanAksesSd   string    `gorm:"size:50;not null"                                json:"kemudahan_akses_sd"`
	ApmSd              string    `gorm:"size:50;not null"                                json:"apm_sd"`
	KemudahanAksesSmp  string    `gorm:"size:50;not null"                                json:"kemudahan_akses_smp"`
	ApmSmp             string    `gorm:"size:50;not null"                                json:"apm_smp"`
	KemudahanAksesSma  string    `gorm:"size:50;not null"                                json:"kemudahan_akses_sma"`
	ApmSma             string    `gorm:"size:50;not null"                                json:"apm_sma"`
	Village            Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiKesehatan struct {
	ID                                         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                                  uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                                       int       `gorm:"size:4"                                          json:"year"`
	KemudahanAksesSaranaKesehatan              string    `gorm:"size:50;not null"                                json:"kemudahan_akses_sarana_kesehatan"`
	KetersediaanFasilitasKesehatan             string    `gorm:"size:50;not null"                                json:"ketersediaan_fasilitas_kesehatan"`
	KemudahanAksesFasilitasKesehatan           string    `gorm:"size:50;not null"                                json:"kemudahan_akses_fasilitas_kesehatan"`
	KetersediaanPosyandu                       string    `gorm:"size:50;not null"                                json:"ketersediaan_posyandu"`
	JumlahAktivitasPosyandu                    string    `gorm:"size:50;not null"                                json:"jumlah_aktivitas_posyandu"`
	KemudahanAksesPosyandu                     string    `gorm:"size:50;not null"                                json:"kemudahan_akses_posyandu"`
	KetersediaanLayananDokter                  string    `gorm:"size:50;not null"                                json:"ketersediaan_layanan_dokter"`
	HariOperasionalLayananDokter               string    `gorm:"size:50;not null"                                json:"hari_operasional_layanan_dokter"`
	PenyediaLayananDokter                      string    `gorm:"size:50;not null"                                json:"penyedia_layanan_dokter"`
	PenyediaTransportasiLayananDokter          string    `gorm:"size:50;not null"                                json:"penyedia_transportasi_layanan_dokter"`
	KetersediaanLayananBidan                   string    `gorm:"size:50;not null"                                json:"ketersediaan_layanan_bidan"`
	HariOperasionalLayananBidan                string    `gorm:"size:50;not null"                                json:"hari_operasional_layanan_bidan"`
	PenyediaLayananBidan                       string    `gorm:"size:50;not null"                                json:"penyedia_layanan_bidan"`
	PenyediaTransportasiLayananBidan           string    `gorm:"size:50;not null"                                json:"penyedia_transportasi_layanan_bidan"`
	KetersediaanLayananTenagaKesehatan         string    `gorm:"size:50;not null"                                json:"ketersediaan_layanan_tenaga_kesehatan"`
	HariOperasionalLayananTenagaKesehatan      string    `gorm:"size:50;not null"                                json:"hari_operasional_layanan_tenaga_kesehatan"`
	PenyediaLayananTenagaKesehatan             string    `gorm:"size:50;not null"                                json:"penyedia_layanan_tenaga_kesehatan"`
	PenyediaTransportasiLayananTenagaKesehatan string    `gorm:"size:50;not null"                                json:"penyedia_transportasi_layanan_tenaga_kesehatan"`
	PersentasePesertaJaminanKesehatan          string    `gorm:"size:50;not null"                                json:"persentase_peserta_jaminan_kesehatan"`
	KegiatanSosialisasiJaminanKesehatan        string    `gorm:"size:50;not null"                                json:"kegiatan_sosialisasi_jaminan_kesehatan"`
	Village                                    Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiUtilitasDasar struct {
	ID                            uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                     uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                          int       `gorm:"size:4"                                          json:"year"`
	OperasionalAirMinum           string    `gorm:"size:50;not null"                                json:"operasional_air_minum"`
	KetersediaanAirMinum          string    `gorm:"size:50;not null"                                json:"ketersediaan_air_minum"`
	KemudahanAksesAirMinum        string    `gorm:"size:50;not null"                                json:"kemudahan_akses_air_minum"`
	KualitasAirMinum              string    `gorm:"size:50;not null"                                json:"kualitas_air_minum"`
	PersentaseRumahTidakLayakHuni string    `gorm:"size:50;not null"                                json:"persentase_rumah_tidak_layak_huni"`
	Village                       Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiAktivitas struct {
	ID                                uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                         uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                              int       `gorm:"size:4"                                          json:"year"`
	KearifanBudayaSosial              string    `gorm:"size:50;not null"                                json:"kearifan_budaya_sosial"`
	KearifanBudayaSosialDipertahankan string    `gorm:"size:50;not null"                                json:"kearifan_budaya_sosial_dipertahankan"`
	KegiatanGotongRoyong              string    `gorm:"size:50;not null"                                json:"kegiatan_gotong_royong"`
	FrekuensiGotongRoyong             string    `gorm:"size:50;not null"                                json:"frekuensi_gotong_royong"`
	KeterlibatanWargaGotongRoyong     string    `gorm:"size:50;not null"                                json:"keterlibatan_warga_gotong_royong"`
	FrekuensiKegiatanOlahraga         string    `gorm:"size:50;not null"                                json:"frekuensi_kegiatan_olahraga"`
	PenyelesaianKonflikSecaraDamai    string    `gorm:"size:50;not null"                                json:"penyelesaian_konflik_secara_damai"`
	PeranAparatKeamananMediator       string    `gorm:"size:50;not null"                                json:"peran_aparat_keamanan_mediator"`
	PeranAparatPemerintah             string    `gorm:"size:50;not null"                                json:"peran_aparat_pemerintah"`
	PeranTokohMasyarakat              string    `gorm:"size:50;not null"                                json:"peran_tokoh_masyarakat"`
	PeranTokohAgama                   string    `gorm:"size:50;not null"                                json:"peran_tokoh_agama"`
	SatuanKeamananLingkungan          string    `gorm:"size:50;not null"                                json:"satuan_keamanan_lingkungan"`
	AktivitasSatuanKeamananLingkungan string    `gorm:"size:50;not null"                                json:"aktivitas_satuan_keamanan_lingkungan"`
	Village                           Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiFasilitasMasyarakat struct {
	ID                                   uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                            uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                                 int       `gorm:"size:4"                                          json:"year"`
	TerdapatTamanBacaanMasyarakat        string    `gorm:"size:50;not null"                                json:"terdapat_taman_bacaan_masyarakat"`
	HariOperasionalTamanBacaanMasyarakat string    `gorm:"size:50;not null"                                json:"hari_operasional_taman_bacaan_masyarakat"`
	KetersediaanFasilitasOlahraga        string    `gorm:"size:50;not null"                                json:"ketersediaan_fasilitas_olahraga"`
	KeberadaanRuangPublikTerbuka         string    `gorm:"size:50;not null"                                json:"keberadaan_ruang_publik_terbuka"`
	Village                              Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiProduksiDesa struct {
	ID                                       uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                                uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                                     int       `gorm:"size:4"                                          json:"year"`
	KeragamanAktivitasEkonomi                string    `gorm:"size:50;not null"                                json:"keragaman_aktivitas_ekonomi"`
	KeaktifanAktivitasEkonomi                string    `gorm:"size:50;not null"                                json:"keaktifan_aktivitas_ekonomi"`
	KetersediaanProdukUnggulanDesa           string    `gorm:"size:50;not null"                                json:"ketersediaan_produk_unggulan_desa"`
	CakupanPasarProdukUnggulan               string    `gorm:"size:50;not null"                                json:"cakupan_pasar_produk_unggulan"`
	KetersediaanMerekDagang                  string    `gorm:"size:50;not null"                                json:"ketersediaan_merek_dagang"`
	TerdapatKearifanLokalEkonomi             string    `gorm:"size:50;not null"                                json:"terdapat_kearifan_lokal_ekonomi"`
	TelahDilakukanKerjaSamaDenganDesaLainnya string    `gorm:"size:50;not null"                                json:"telah_dilakukan_kerja_sama_dengan_desa_lainnya"`
	TelahDilakukanKerjaSamaDenganPihakKetiga string    `gorm:"size:50;not null"                                json:"telah_dilakukan_kerja_sama_dengan_pihak_ketiga"`
	Village                                  Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiFasilitasPendukungEkonomi struct {
	ID                                uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                         uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                              int       `gorm:"size:4"                                          json:"year"`
	KetersediaanPendidikanNonFormal   string    `gorm:"size:50;not null"                                json:"ketersediaan_pendidikan_non_formal"`
	KeterlibatanPendidikanNonFormal   string    `gorm:"size:50;not null"                                json:"keterlibatan_pendidikan_non_formal"`
	KetersediaanPasarRakyat           string    `gorm:"size:50;not null"                                json:"ketersediaan_pasar_rakyat"`
	KemudahanAksesPasarRakyat         string    `gorm:"size:50;not null"                                json:"kemudahan_akses_pasar_rakyat"`
	KetersediaanToko                  string    `gorm:"size:50;not null"                                json:"ketersediaan_toko"`
	KemudahanAksesToko                string    `gorm:"size:50;not null"                                json:"kemudahan_akses_toko"`
	KetersediaanRumahMakan            string    `gorm:"size:50;not null"                                json:"ketersediaan_rumah_makan"`
	KemudahanAksesRumahMakan          string    `gorm:"size:50;not null"                                json:"kemudahan_akses_rumah_makan"`
	KetersediaanPenginapan            string    `gorm:"size:50;not null"                                json:"ketersediaan_penginapan"`
	KemudahanAksesPenginapan          string    `gorm:"size:50;not null"                                json:"kemudahan_akses_penginapan"`
	KetersediaanLogistik              string    `gorm:"size:50;not null"                                json:"ketersediaan_logistik"`
	KemudahanAksesLogistik            string    `gorm:"size:50;not null"                                json:"kemudahan_akses_logistik"`
	TerdapatBumd                      string    `gorm:"size:50;not null"                                json:"terdapat_bumd"`
	BumdBerbadanHukum                 string    `gorm:"size:50;not null"                                json:"bumd_berbadan_hukum"`
	HariOperasionalLembagaEkonomi     string    `gorm:"size:50;not null"                                json:"hari_operasional_lembaga_ekonomi"`
	KetersediaanLembagaEkonomiLainnya string    `gorm:"size:50;not null"                                json:"ketersediaan_lembaga_ekonomi_lainnya"`
	KetersediaanKud                   string    `gorm:"size:50;not null"                                json:"ketersediaan_kud"`
	KetersediaanUmkm                  string    `gorm:"size:50;not null"                                json:"ketersediaan_umkm"`
	LayananPerbankan                  string    `gorm:"size:50;not null"                                json:"layanan_perbankan"`
	HariOperasionalKeuangan           string    `gorm:"size:50;not null"                                json:"hari_operasional_keuangan"`
	LayananFasilitasKreditKur         string    `gorm:"size:50;not null"                                json:"layanan_fasilitas_kredit_kur"`
	LayananFasilitasKreditKkpE        string    `gorm:"size:50;not null"                                json:"layanan_fasilitas_kredit_kkp_e"`
	LayananFasilitasKreditKuk         string    `gorm:"size:50;not null"                                json:"layanan_fasilitas_kredit_kuk"`
	StatusLayananFasilitasKredit      string    `gorm:"size:50;not null"                                json:"status_layanan_fasilitas_kredit"`
	Village                           Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiPengelolaanLingkungan struct {
	ID                                uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                         uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                              int       `gorm:"size:4"                                          json:"year"`
	UpayaMenjagaKelestarianLingkungan string    `gorm:"size:50;not null"                                json:"upaya_menjaga_kelestarian_lingkungan"`
	RegulasiPelestarianLingkungan     string    `gorm:"size:50;not null"                                json:"regulasi_pelestarian_lingkungan"`
	KegiatanPelestarianLingkungan     string    `gorm:"size:50;not null"                                json:"kegiatan_pelestarian_lingkungan"`
	PemanfaatanEnergiTerbarukan       string    `gorm:"size:50;not null"                                json:"pemanfaatan_energi_terbarukan"`
	TempatPembuananganSampah          string    `gorm:"size:50;not null"                                json:"tempat_pembuanangan_sampah"`
	PengelolaanSampah                 string    `gorm:"size:50;not null"                                json:"pengelolaan_sampah"`
	PemanfaatanSampah                 string    `gorm:"size:50;not null"                                json:"pemanfaatan_sampah"`
	KejadianPencemaranLingkungan      string    `gorm:"size:50;not null"                                json:"kejadian_pencemaran_lingkungan"`
	KetersediaanJamban                string    `gorm:"size:50;not null"                                json:"ketersediaan_jamban"`
	KeberfungsianJamban               string    `gorm:"size:50;not null"                                json:"keberfungsian_jamban"`
	KetersediaanSepticTank            string    `gorm:"size:50;not null"                                json:"ketersediaan_septic_tank"`
	PembuanganAirLimbahCairRumah      string    `gorm:"size:50;not null"                                json:"pembuangan_air_limbah_cair_rumah"`
	Village                           Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiPenanggulanganBencana struct {
	ID                                  uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                           uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                                int       `gorm:"size:4"                                          json:"year"`
	AspekInformasiKebencanaan           string    `gorm:"size:50;not null"                                json:"aspek_informasi_kebencanaan"`
	FasilitasMitigasiBencana            string    `gorm:"size:50;not null"                                json:"fasilitas_mitigasi_bencana"`
	AksesMenujuFasilitasMitigasiBencana string    `gorm:"size:50;not null"                                json:"akses_menuju_fasilitas_mitigasi_bencana"`
	AktivitasMitigasi                   string    `gorm:"size:50;not null"                                json:"aktivitas_mitigasi"`
	FasilitasTanggapDaruratBencana      string    `gorm:"size:50;not null"                                json:"fasilitas_tanggap_darurat_bencana"`
	Village                             Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiKondisiAksesJalan struct {
	ID                   uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID            uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                 int       `gorm:"size:4"                                          json:"year"`
	JenisPermukaanJalan  string    `gorm:"size:50;not null"                                json:"jenis_permukaan_jalan"`
	KualitasJalan        string    `gorm:"size:50;not null"                                json:"kualitas_jalan"`
	PeneranganJalanUtama string    `gorm:"size:50;not null"                                json:"penerangan_jalan_utama"`
	OperasionalPju       string    `gorm:"size:50;not null"                                json:"operasional_pju"`
	Village              Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiKemudahanAkses struct {
	ID                           uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                    uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                         int       `gorm:"size:4"                                          json:"year"`
	AngkutanPerdesaan            string    `gorm:"size:50;not null"                                json:"angkutan_perdesaan"`
	OperasionalAngkutanPerdesaan string    `gorm:"size:50;not null"                                json:"operasional_angkutan_perdesaan"`
	PelayananListrik             string    `gorm:"size:50;not null"                                json:"pelayanan_listrik"`
	DurasiLayananListrik         string    `gorm:"size:50;not null"                                json:"durasi_layanan_listrik"`
	AksesTelepon                 string    `gorm:"size:50;not null"                                json:"akses_telepon"`
	AksesInternet                string    `gorm:"size:50;not null"                                json:"akses_internet"`
	Village                      Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiKelembagaanPelayananDesa struct {
	ID                                     uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID                              uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                                   int       `gorm:"size:4"                                          json:"year"`
	LayananDiberikan                       string    `gorm:"size:50;not null"                                json:"layanan_diberikan"`
	PublikasiInformasiPelayanan            string    `gorm:"size:50;not null"                                json:"publikasi_informasi_pelayanan"`
	PelayananAdministrasi                  string    `gorm:"size:50;not null"                                json:"pelayanan_administrasi"`
	PelayananPengaduan                     string    `gorm:"size:50;not null"                                json:"pelayanan_pengaduan"`
	PelayananLainnya                       string    `gorm:"size:50;not null"                                json:"pelayanan_lainnya"`
	MusyawarahDesa                         string    `gorm:"size:50;not null"                                json:"musyawarah_desa"`
	MusyawarahDesaDidatangiUnsurMasyarakat string    `gorm:"size:50;not null"                                json:"musyawarah_desa_didatangi_unsur_masyarakat"`
	Village                                Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}

type SubDimensiTataKelolaKeuanganDesa struct {
	ID                    uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	VillageID             uuid.UUID `gorm:"type:uuid;not null"                              json:"village_id"`
	Year                  int       `gorm:"size:4"                                          json:"year"`
	PendapatanAsliDesa    string    `gorm:"size:50;not null"                                json:"pendapatan_asli_desa"`
	PeningkatanPades      string    `gorm:"size:50;not null"                                json:"peningkatan_pades"`
	PenyertaanModalDdBumd string    `gorm:"size:50;not null"                                json:"penyertaan_modal_dd_bumd"`
	AsetTanahDesa         string    `gorm:"size:50;not null"                                json:"aset_tanah_desa"`
	AsetKantorDesa        string    `gorm:"size:50;not null"                                json:"aset_kantor_desa"`
	AsetPasarDesa         string    `gorm:"size:50;not null"                                json:"aset_pasar_desa"`
	AsetLainnya           string    `gorm:"size:50;not null"                                json:"aset_lainnya"`
	ProduktivitasAsetDesa string    `gorm:"size:50;not null"                                json:"produktivitas_aset_desa"`
	InventarisasiAsetDesa string    `gorm:"size:50;not null"                                json:"inventarisasi_aset_desa"`
	Village               Village   `gorm:"foreignKey:VillageID"                            json:"-"`
}
