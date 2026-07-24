package services

import (
	"bytes"
	"fmt"

	"Apps-I_Desa_Backend/dtos"
	"github.com/xuri/excelize/v2"
)

const (
	importSheetData  = "Data Penduduk"
	importSheetGuide = "Petunjuk"

	importDataRowStart = 2
	importDataRowEnd   = 1000
)

// importDataColumns is the single source of truth for column order in the
// generated template. import.service.go indexes into GetRows results using
// these same positions, so header text and parsing position can never
// silently drift apart.
//
// One sheet, one row per person — not two sheets linked by Nomor KK. Columns
// 1-16 mirror the Buku Induk Penduduk ledger's own column order exactly
// (Nomor Urut, ..., Ket), so a village with that ledger can select an entire
// row and paste it in one motion. Four of those — Nomor Urut, Dapat Membaca
// Huruf, Ket, and (unlike before) NOT Alamat Lengkap — have no matching
// field and are ignored on import (see importDataIgnoredColumns); Alamat
// Lengkap now feeds family_cards.Alamat, since the real ledger already
// repeats that value on every member's row.
//
// Columns 17-23 (RT/RW/Kelurahan/Kecamatan/Kabupaten-Kota/Kode Pos/Provinsi)
// are new: the ledger has no equivalent, but family_cards needs them. Only
// the first row of a given Nomor KK needs these filled in — see
// resolvePersonGroups in import.service.go — so a village whose source is
// individual KK cards (not a ledger) fills them once per card, and a village
// pasting straight from the ledger can just leave them blank since the
// ledger never had them either.
//
// Nama Ayah/Nama Ibu/Nomor Paspor/Nomor KITAS stay appended at the end,
// since the ledger doesn't carry them at all.
var importDataColumns = []string{
	"Nomor Urut (diabaikan)", "Nama Lengkap", "Jenis Kelamin", "Status Perkawinan",
	"Tempat Lahir", "Tanggal Lahir", "Agama", "Pendidikan Terakhir", "Pekerjaan",
	"Dapat Membaca Huruf (diabaikan)", "Kewarganegaraan", "Alamat Lengkap",
	"Kedudukan Dalam Keluarga", "NIK", "Nomor KK", "Ket (diabaikan)",
	"RT", "RW", "Kelurahan", "Kecamatan", "Kabupaten/Kota", "Kode Pos", "Provinsi",
	"Nama Ayah", "Nama Ibu", "Nomor Paspor", "Nomor KITAS",
}

// 1-based positions (within importDataColumns) that the parser never reads —
// kept only so a full ledger row pastes without gaps.
var importDataIgnoredColumns = map[int]bool{1: true, 10: true, 16: true}

// 1-based positions (within importDataColumns) of dropdown-backed columns.
// All ≤ 16, so these did not shift when columns 17-23 were inserted after
// the ledger-matching block.
const (
	colDataJenisKelamin      = 3
	colDataStatusPerkawinan  = 4
	colDataTanggalLahir      = 6
	colDataAgama             = 7
	colDataPendidikan        = 8
	colDataKewarganegaraan   = 11
	colDataKedudukanKeluarga = 13
	colDataNIK               = 14
)

type ImportTemplateService struct{}

func NewImportTemplateService() *ImportTemplateService {
	return &ImportTemplateService{}
}

// GenerateTemplate builds the downloadable import workbook fresh on every
// call: one "Data Penduduk" sheet with Excel-native dropdowns and date
// validation, plus a Petunjuk (instructions) sheet.
func (s *ImportTemplateService) GenerateTemplate() (*bytes.Buffer, error) {
	f := excelize.NewFile()
	defer f.Close()

	if err := f.SetSheetName("Sheet1", importSheetData); err != nil {
		return nil, err
	}
	if _, err := f.NewSheet(importSheetGuide); err != nil {
		return nil, err
	}
	f.SetActiveSheet(0)

	headerStyle, err := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Bold: true, Color: "FFFFFF"},
		Fill: excelize.Fill{Type: "pattern", Color: []string{"2E7D32"}, Pattern: 1},
	})
	if err != nil {
		return nil, err
	}

	if err := writeHeaderRow(f, importSheetData, importDataColumns, headerStyle); err != nil {
		return nil, err
	}

	if err := addDataDropdowns(f); err != nil {
		return nil, err
	}
	if err := addDataDateValidation(f); err != nil {
		return nil, err
	}
	if err := addNikLengthHint(f); err != nil {
		return nil, err
	}
	if err := markIgnoredDataColumns(f); err != nil {
		return nil, err
	}

	if err := writeGuideSheet(f); err != nil {
		return nil, err
	}

	return f.WriteToBuffer()
}

func writeHeaderRow(f *excelize.File, sheet string, headers []string, styleID int) error {
	for i, h := range headers {
		cell, err := excelize.CoordinatesToCellName(i+1, 1)
		if err != nil {
			return err
		}
		if err := f.SetCellValue(sheet, cell, h); err != nil {
			return err
		}
	}
	lastCol, err := excelize.ColumnNumberToName(len(headers))
	if err != nil {
		return err
	}
	if err := f.SetColWidth(sheet, "A", lastCol, 22); err != nil {
		return err
	}
	return f.SetCellStyle(sheet, "A1", lastCol+"1", styleID)
}

func addDataDropdowns(f *excelize.File) error {
	dropdowns := map[int][]string{
		colDataJenisKelamin:      dtos.ImportJenisKelaminOptions,
		colDataStatusPerkawinan:  dtos.ImportStatusPerkawinanOptions,
		colDataAgama:             dtos.ImportAgamaOptions,
		colDataPendidikan:        dtos.ImportPendidikanOptions,
		colDataKewarganegaraan:   dtos.ImportKewarganegaraanOptions,
		colDataKedudukanKeluarga: dtos.ImportStatusHubunganOptions,
	}

	for col, options := range dropdowns {
		colName, err := excelize.ColumnNumberToName(col)
		if err != nil {
			return err
		}

		dv := excelize.NewDataValidation(true)
		dv.Sqref = fmt.Sprintf("%s%d:%s%d", colName, importDataRowStart, colName, importDataRowEnd)
		if err := dv.SetDropList(options); err != nil {
			return err
		}
		dv.SetError(excelize.DataValidationErrorStyleStop, "Pilihan Tidak Valid", "Pilih salah satu nilai dari daftar dropdown di kolom ini.")

		if err := f.AddDataValidation(importSheetData, dv); err != nil {
			return err
		}
	}

	return nil
}

// addDataDateValidation restricts Tanggal Lahir to real dates between
// 1900-01-01 and today. excelize does not expose a public helper to convert a
// time.Time into its serial-date form, so the bounds are passed as plain
// Excel formula strings — this sidesteps hand-rolling the 1900 leap-year-bug
// date math ourselves.
func addDataDateValidation(f *excelize.File) error {
	col, err := excelize.ColumnNumberToName(colDataTanggalLahir)
	if err != nil {
		return err
	}

	dv := excelize.NewDataValidation(true)
	dv.Sqref = fmt.Sprintf("%s%d:%s%d", col, importDataRowStart, col, importDataRowEnd)
	if err := dv.SetRange("DATE(1900,1,1)", "TODAY()", excelize.DataValidationTypeDate, excelize.DataValidationOperatorBetween); err != nil {
		return err
	}
	dv.SetError(excelize.DataValidationErrorStyleStop, "Format Tanggal Salah",
		"Masukkan tanggal lahir sebagai tanggal (bukan teks), antara 1 Januari 1900 dan hari ini.")
	if err := f.AddDataValidation(importSheetData, dv); err != nil {
		return err
	}

	dateFmt := "dd/mm/yyyy"
	styleID, err := f.NewStyle(&excelize.Style{CustomNumFmt: &dateFmt})
	if err != nil {
		return err
	}
	return f.SetCellStyle(importSheetData, col+"2", fmt.Sprintf("%s%d", col, importDataRowEnd), styleID)
}

// addNikLengthHint is a soft assist only (Warning, not Stop): Excel's
// text-length check confirms 16 characters but not that they're digits, so a
// hard block here could wrongly reject an edge case. Real validation happens
// on the backend at upload time regardless.
func addNikLengthHint(f *excelize.File) error {
	col, err := excelize.ColumnNumberToName(colDataNIK)
	if err != nil {
		return err
	}

	dv := excelize.NewDataValidation(true)
	dv.Sqref = fmt.Sprintf("%s%d:%s%d", col, importDataRowStart, col, importDataRowEnd)
	if err := dv.SetRange(16, 16, excelize.DataValidationTypeTextLength, excelize.DataValidationOperatorEqual); err != nil {
		return err
	}
	dv.SetError(excelize.DataValidationErrorStyleWarning, "Periksa Kembali NIK",
		"NIK biasanya terdiri dari 16 digit. Sistem akan memvalidasi ulang saat file diunggah.")

	return f.AddDataValidation(importSheetData, dv)
}

// markIgnoredDataColumns greys out the columns kept purely for
// paste-compatibility with the Buku Induk Penduduk ledger (see
// importDataIgnoredColumns) so it's visually obvious — not just stated in
// the header text — that nothing typed there gets saved.
func markIgnoredDataColumns(f *excelize.File) error {
	ignoredStyle, err := f.NewStyle(&excelize.Style{
		Fill: excelize.Fill{Type: "pattern", Color: []string{"F0F0F0"}, Pattern: 1},
		Font: &excelize.Font{Italic: true, Color: "999999"},
	})
	if err != nil {
		return err
	}

	for col := range importDataIgnoredColumns {
		colName, err := excelize.ColumnNumberToName(col)
		if err != nil {
			return err
		}
		if err := f.SetCellStyle(
			importSheetData,
			colName+"2",
			fmt.Sprintf("%s%d", colName, importDataRowEnd),
			ignoredStyle,
		); err != nil {
			return err
		}
	}

	return nil
}

func writeGuideSheet(f *excelize.File) error {
	lines := []string{
		"PETUNJUK PENGISIAN TEMPLATE IMPORT DATA",
		"",
		"1. Satu sheet saja: \"Data Penduduk\". Satu baris = satu orang.",
		"2. Penduduk dalam satu keluarga punya Nomor KK yang SAMA — tulis Nomor KK yang sama di setiap baris anggota keluarga itu.",
		"3. Kolom Alamat Lengkap, RT, RW, Kelurahan, Kecamatan, Kabupaten/Kota, Kode Pos, dan Provinsi HANYA WAJIB diisi pada baris PERTAMA setiap Nomor KK baru — baris itu yang dipakai sistem untuk membuat data Kartu Keluarga. Baris anggota berikutnya dari Nomor KK yang sama boleh dikosongkan pada kolom-kolom ini.",
		"4. Kalau sumber data Anda Buku Induk Penduduk (buku besar yang alamatnya memang tertulis berulang di setiap baris), tinggal salin apa adanya — tidak perlu dihapus dulu.",
		"5. Kalau sumber data Anda kartu Kartu Keluarga satuan (bukan buku besar), isi satu kartu = isi beberapa baris berurutan ke bawah untuk anggota kartu itu di sheet yang sama — alamat cukup ditulis di baris pertama saja, tidak perlu pindah sheet.",
		"6. RT, RW, dan Kode Pos boleh dikosongkan kalau memang belum ada datanya.",
		"7. NIK harus 16 digit angka dan wajib diisi untuk setiap penduduk.",
		"8. Tanggal Lahir harus diisi sebagai tanggal asli (klik sel, pilih tanggal dari kalender), bukan diketik sebagai teks.",
		"9. Kolom dengan dropdown (Jenis Kelamin, Agama, Pendidikan Terakhir, Status Perkawinan, Kedudukan Dalam Keluarga, Kewarganegaraan) wajib dipilih dari daftar yang muncul, bukan diketik bebas.",
		"10. Baris dengan Nomor KK yang sudah terdaftar di sistem akan dilewati (tidak dianggap error) dan dilaporkan terpisah setelah unggah — anggota keluarganya tetap akan diproses.",
		"11. Setelah unggah, sistem akan menampilkan laporan: baris mana yang berhasil, dilewati, atau gagal, beserta alasannya.",
		"12. Kolom \"Nomor Urut\", \"Dapat Membaca Huruf\", dan \"Ket\" (ditandai abu-abu) sengaja disediakan supaya satu baris dari Buku Induk Penduduk bisa langsung disalin utuh tanpa lompat kolom. Sistem TIDAK menyimpan isi kolom-kolom ini — boleh dikosongkan atau dibiarkan apa adanya.",
	}

	for i, line := range lines {
		cell, err := excelize.CoordinatesToCellName(1, i+1)
		if err != nil {
			return err
		}
		if err := f.SetCellValue(importSheetGuide, cell, line); err != nil {
			return err
		}
	}

	return f.SetColWidth(importSheetGuide, "A", "A", 100)
}
