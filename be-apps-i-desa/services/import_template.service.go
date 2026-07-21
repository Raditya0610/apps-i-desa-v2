package services

import (
	"bytes"
	"fmt"

	"Apps-I_Desa_Backend/dtos"
	"github.com/xuri/excelize/v2"
)

const (
	importSheetFamilyCards = "Kartu Keluarga"
	importSheetVillagers   = "Anggota Keluarga"
	importSheetGuide       = "Petunjuk"

	importDataRowStart = 2
	importDataRowEnd   = 1000
)

// importFamilyCardColumns and importVillagerColumns are the single source of
// truth for column order in the generated template. import.service.go indexes
// into GetRows results using these same positions, so header text and parsing
// position can never silently drift apart.
var importFamilyCardColumns = []string{
	"Nomor KK", "Alamat Lengkap", "RT", "RW", "Kelurahan", "Kecamatan",
	"Kabupaten/Kota", "Kode Pos", "Provinsi",
}

// importVillagerColumns mirrors the Buku Induk Penduduk ledger's own column
// order exactly (Nomor Urut, ..., Ket), not just the fields the system
// stores. Four of these columns — Nomor Urut, Dapat Membaca Huruf, Alamat
// Lengkap, Ket — have no matching Villager field and are ignored on import
// (see importVillagerIgnoredColumns). They're kept in the template anyway so
// a village can select an entire row straight out of their ledger and paste
// it in one motion instead of pasting around gaps. Nama Ayah/Nama Ibu/Nomor
// Paspor/Nomor KITAS are appended at the end since the ledger doesn't carry
// them at all.
var importVillagerColumns = []string{
	"Nomor Urut (diabaikan)", "Nama Lengkap", "Jenis Kelamin", "Status Perkawinan",
	"Tempat Lahir", "Tanggal Lahir", "Agama", "Pendidikan Terakhir", "Pekerjaan",
	"Dapat Membaca Huruf (diabaikan)", "Kewarganegaraan", "Alamat Lengkap (diabaikan)",
	"Kedudukan Dalam Keluarga", "NIK", "Nomor KK", "Ket (diabaikan)",
	"Nama Ayah", "Nama Ibu", "Nomor Paspor", "Nomor KITAS",
}

// 1-based positions (within importVillagerColumns) that the parser never
// reads — kept only so a full ledger row pastes without gaps.
var importVillagerIgnoredColumns = map[int]bool{1: true, 10: true, 12: true, 16: true}

// 1-based positions (within importVillagerColumns) of dropdown-backed columns.
const (
	colVillagerJenisKelamin      = 3
	colVillagerStatusPerkawinan  = 4
	colVillagerTanggalLahir      = 6
	colVillagerAgama             = 7
	colVillagerPendidikan        = 8
	colVillagerKewarganegaraan   = 11
	colVillagerKedudukanKeluarga = 13
	colVillagerNIK               = 14
)

type ImportTemplateService struct{}

func NewImportTemplateService() *ImportTemplateService {
	return &ImportTemplateService{}
}

// GenerateTemplate builds the downloadable import workbook fresh on every
// call: Kartu Keluarga + Anggota Keluarga sheets with Excel-native dropdowns
// and date validation, plus a Petunjuk (instructions) sheet.
func (s *ImportTemplateService) GenerateTemplate() (*bytes.Buffer, error) {
	f := excelize.NewFile()
	defer f.Close()

	if err := f.SetSheetName("Sheet1", importSheetFamilyCards); err != nil {
		return nil, err
	}
	if _, err := f.NewSheet(importSheetVillagers); err != nil {
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

	if err := writeHeaderRow(f, importSheetFamilyCards, importFamilyCardColumns, headerStyle); err != nil {
		return nil, err
	}
	if err := writeHeaderRow(f, importSheetVillagers, importVillagerColumns, headerStyle); err != nil {
		return nil, err
	}

	if err := addFamilyCardExampleRow(f); err != nil {
		return nil, err
	}

	if err := addVillagerDropdowns(f); err != nil {
		return nil, err
	}
	if err := addVillagerDateValidation(f); err != nil {
		return nil, err
	}
	if err := addNikLengthHint(f); err != nil {
		return nil, err
	}
	if err := markIgnoredVillagerColumns(f); err != nil {
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

// addFamilyCardExampleRow fills row 2 with sample values so villages see the
// expected shape before entering real data; the guide sheet tells them to
// delete it.
func addFamilyCardExampleRow(f *excelize.File) error {
	example := []interface{}{
		"3271010101010001", "Ohoi Contoh", "001", "002", "Ohoi Contoh",
		"Kei Kecil Timur Selatan", "Maluku Tenggara", "97651", "Maluku",
	}
	for i, v := range example {
		cell, err := excelize.CoordinatesToCellName(i+1, 2)
		if err != nil {
			return err
		}
		if err := f.SetCellValue(importSheetFamilyCards, cell, v); err != nil {
			return err
		}
	}

	italicGray, err := f.NewStyle(&excelize.Style{Font: &excelize.Font{Italic: true, Color: "888888"}})
	if err != nil {
		return err
	}
	lastCol, err := excelize.ColumnNumberToName(len(importFamilyCardColumns))
	if err != nil {
		return err
	}
	return f.SetCellStyle(importSheetFamilyCards, "A2", lastCol+"2", italicGray)
}

func addVillagerDropdowns(f *excelize.File) error {
	dropdowns := map[int][]string{
		colVillagerJenisKelamin:      dtos.ImportJenisKelaminOptions,
		colVillagerStatusPerkawinan:  dtos.ImportStatusPerkawinanOptions,
		colVillagerAgama:             dtos.ImportAgamaOptions,
		colVillagerPendidikan:        dtos.ImportPendidikanOptions,
		colVillagerKewarganegaraan:   dtos.ImportKewarganegaraanOptions,
		colVillagerKedudukanKeluarga: dtos.ImportStatusHubunganOptions,
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

		if err := f.AddDataValidation(importSheetVillagers, dv); err != nil {
			return err
		}
	}

	return nil
}

// addVillagerDateValidation restricts Tanggal Lahir to real dates between
// 1900-01-01 and today. excelize does not expose a public helper to convert a
// time.Time into its serial-date form, so the bounds are passed as plain
// Excel formula strings — this sidesteps hand-rolling the 1900 leap-year-bug
// date math ourselves.
func addVillagerDateValidation(f *excelize.File) error {
	col, err := excelize.ColumnNumberToName(colVillagerTanggalLahir)
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
	if err := f.AddDataValidation(importSheetVillagers, dv); err != nil {
		return err
	}

	dateFmt := "dd/mm/yyyy"
	styleID, err := f.NewStyle(&excelize.Style{CustomNumFmt: &dateFmt})
	if err != nil {
		return err
	}
	return f.SetCellStyle(importSheetVillagers, col+"2", fmt.Sprintf("%s%d", col, importDataRowEnd), styleID)
}

// addNikLengthHint is a soft assist only (Warning, not Stop): Excel's
// text-length check confirms 16 characters but not that they're digits, so a
// hard block here could wrongly reject an edge case. Real validation happens
// on the backend at upload time regardless.
func addNikLengthHint(f *excelize.File) error {
	col, err := excelize.ColumnNumberToName(colVillagerNIK)
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

	return f.AddDataValidation(importSheetVillagers, dv)
}

// markIgnoredVillagerColumns greys out the columns kept purely for
// paste-compatibility with the Buku Induk Penduduk ledger (see
// importVillagerIgnoredColumns) so it's visually obvious — not just stated in
// the header text — that nothing typed there gets saved.
func markIgnoredVillagerColumns(f *excelize.File) error {
	ignoredStyle, err := f.NewStyle(&excelize.Style{
		Fill: excelize.Fill{Type: "pattern", Color: []string{"F0F0F0"}, Pattern: 1},
		Font: &excelize.Font{Italic: true, Color: "999999"},
	})
	if err != nil {
		return err
	}

	for col := range importVillagerIgnoredColumns {
		colName, err := excelize.ColumnNumberToName(col)
		if err != nil {
			return err
		}
		if err := f.SetCellStyle(
			importSheetVillagers,
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
		"1. Sheet \"Kartu Keluarga\" — satu baris per kartu keluarga. Baris ke-2 adalah CONTOH, hapus sebelum mengisi data asli.",
		"2. Sheet \"Anggota Keluarga\" — satu baris per penduduk. Kolom \"Nomor KK\" harus sama persis dengan salah satu Nomor KK di sheet \"Kartu Keluarga\", atau Nomor KK yang sudah terdaftar di sistem.",
		"3. NIK harus 16 digit angka dan wajib diisi untuk setiap penduduk.",
		"4. Tanggal Lahir harus diisi sebagai tanggal asli (klik sel, pilih tanggal dari kalender), bukan diketik sebagai teks.",
		"5. Kolom dengan dropdown (Jenis Kelamin, Agama, Pendidikan Terakhir, Status Perkawinan, Kedudukan Dalam Keluarga, Kewarganegaraan) wajib dipilih dari daftar yang muncul, bukan diketik bebas.",
		"6. RT, RW, dan Kode Pos boleh dikosongkan jika belum ada datanya.",
		"7. Baris dengan Nomor KK yang sudah terdaftar di sistem akan dilewati (tidak dianggap error) dan dilaporkan terpisah setelah unggah — anggota keluarganya tetap akan diproses.",
		"8. Setelah unggah, sistem akan menampilkan laporan: baris mana yang berhasil, dilewati, atau gagal, beserta alasannya.",
		"9. Kolom \"Nomor Urut\", \"Dapat Membaca Huruf\", \"Alamat Lengkap\", dan \"Ket\" pada sheet \"Anggota Keluarga\" (ditandai abu-abu) sengaja disediakan supaya satu baris dari Buku Induk Penduduk bisa langsung disalin utuh tanpa lompat kolom. Sistem TIDAK menyimpan isi kolom-kolom ini — boleh dikosongkan atau dibiarkan apa adanya.",
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
