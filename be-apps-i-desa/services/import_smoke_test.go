package services

import (
	"testing"

	"Apps-I_Desa_Backend/dtos"
	"github.com/xuri/excelize/v2"
)

func TestImportTemplateSmoke(t *testing.T) {
	svc := NewImportTemplateService()
	buf, err := svc.GenerateTemplate()
	if err != nil {
		t.Fatalf("GenerateTemplate failed: %v", err)
	}

	f, err := excelize.OpenReader(buf)
	if err != nil {
		t.Fatalf("failed to reopen generated template: %v", err)
	}
	defer f.Close()

	rows, err := f.GetRows(importSheetData)
	if err != nil {
		t.Fatalf("missing sheet %s: %v", importSheetData, err)
	}
	if len(rows) < 1 || len(rows[0]) != len(importDataColumns) {
		t.Fatalf("unexpected header row: %v", rows)
	}

	if _, err := f.GetRows(importSheetGuide); err != nil {
		t.Fatalf("missing guide sheet: %v", err)
	}

	dvs, err := f.GetDataValidations(importSheetData)
	if err != nil {
		t.Fatalf("GetDataValidations failed: %v", err)
	}
	if len(dvs) == 0 {
		t.Fatalf("expected data validations on %s, found none", importSheetData)
	}
	t.Logf("found %d data validations on %s", len(dvs), importSheetData)
}

// TestParsePersonRowsFromGeneratedTemplate writes a real row into the actual
// generated template, reloads it through excelize, and checks that
// parsePersonRows lands every value in the right field — catching a
// column-index mistake that a hand-built personRow struct in
// TestResolvePersonRows would never expose.
func TestParsePersonRowsFromGeneratedTemplate(t *testing.T) {
	svc := NewImportTemplateService()
	buf, err := svc.GenerateTemplate()
	if err != nil {
		t.Fatalf("GenerateTemplate failed: %v", err)
	}

	f, err := excelize.OpenReader(buf)
	if err != nil {
		t.Fatalf("failed to reopen generated template: %v", err)
	}
	defer f.Close()

	values := []any{
		"1", "Budi Santoso", "Laki-laki", "Kawin", "Kei Kecil", "15/08/1980",
		"Islam", "SLTA/Sederajat", "Petani", "Ya", "WNI", "Ohoi Ngursoin",
		"Kepala Keluarga", "8102151508800001", "3271010101010001", "-",
		"001", "002", "Ohoi Ngursoin", "Kei Kecil Timur Selatan", "Maluku Tenggara",
		"97652", "Maluku", "Ahmad Yani", "Siti Aminah", "A1234567", "KITAS998877",
	}
	if len(values) != len(importDataColumns) {
		t.Fatalf("test fixture has %d values, template has %d columns", len(values), len(importDataColumns))
	}
	for i, v := range values {
		cellName, _ := excelize.CoordinatesToCellName(i+1, 2)
		if err := f.SetCellValue(importSheetData, cellName, v); err != nil {
			t.Fatalf("SetCellValue: %v", err)
		}
	}

	rawRows, err := f.GetRows(importSheetData)
	if err != nil {
		t.Fatalf("GetRows failed: %v", err)
	}
	rows := parsePersonRows(rawRows)
	if len(rows) != 1 {
		t.Fatalf("expected 1 parsed row, got %d", len(rows))
	}
	r := rows[0]

	want := personRow{
		RowNum: 2, NamaLengkap: "Budi Santoso", JenisKelamin: "Laki-laki",
		StatusPerkawinan: "Kawin", TempatLahir: "Kei Kecil", TanggalLahirRaw: "15/08/1980",
		Agama: "Islam", Pendidikan: "SLTA/Sederajat", Pekerjaan: "Petani",
		Kewarganegaraan: "WNI", Alamat: "Ohoi Ngursoin", StatusHubungan: "Kepala Keluarga",
		NIK: "8102151508800001", NomorKK: "3271010101010001",
		RT: "001", RW: "002", Kelurahan: "Ohoi Ngursoin", Kecamatan: "Kei Kecil Timur Selatan",
		KabupatenKota: "Maluku Tenggara", KodePos: "97652", Provinsi: "Maluku",
		NamaAyah: "Ahmad Yani", NamaIbu: "Siti Aminah", NomorPaspor: "A1234567", NomorKitas: "KITAS998877",
	}
	if r != want {
		t.Errorf("parsePersonRows mismatch:\n got:  %+v\n want: %+v", r, want)
	}
}

func TestParseTanggalLahir(t *testing.T) {
	cases := map[string]bool{
		"20/07/2026": true,
		"2026-07-20": true,
		"45859":      true, // excel serial fallback
		"24-062003":  false,
		"":           false,
		"bukan tanggal": false,
	}
	for raw, wantOK := range cases {
		_, err := parseTanggalLahir(raw)
		gotOK := err == nil
		if gotOK != wantOK {
			t.Errorf("parseTanggalLahir(%q) ok=%v, want %v (err=%v)", raw, gotOK, wantOK, err)
		}
	}
}

func TestValidateEnumOption(t *testing.T) {
	if reason := validateEnumOption("Jenis Kelamin", "Laki-laki", []string{"Laki-laki", "Perempuan"}); reason != "" {
		t.Errorf("expected valid option to pass, got reason: %s", reason)
	}
	if reason := validateEnumOption("Jenis Kelamin", "Pria", []string{"Laki-laki", "Perempuan"}); reason == "" {
		t.Errorf("expected invalid option to fail")
	}
}

func TestTranslateValidationErrors(t *testing.T) {
	req := buildFamilyCardRequest(familyFields{NIK: "123"}) // too short, other required fields blank
	v := NewImportService(nil, nil)
	err := v.validate.Struct(&req)
	if err == nil {
		t.Fatalf("expected validation error")
	}
	msg := translateValidationErrors(err, familyCardFieldLabels)
	t.Logf("translated: %s", msg)
	if msg == err.Error() {
		t.Errorf("expected translated Indonesian message, got raw validator error")
	}
}

// TestResolvePersonRows exercises the single-sheet grouping algorithm
// directly (no DB needed — resolvePersonRows and resolveFamilyGroup only
// touch s.validate) against the scenarios from the redesign plan: ledger
// style (address repeated every row), KK-card style (address only on the
// first row), a mismatched repeat, an unresolvable new family, an existing
// in-village family, a cross-village collision, and the older per-row
// validation scenarios (duplicate NIK, bad enum, bad date, missing field,
// blank Nama Ayah/Ibu).
func TestResolvePersonRows(t *testing.T) {
	s := NewImportService(nil, nil)

	base := func(kk, nik, nama string) personRow {
		return personRow{
			NamaLengkap: nama, JenisKelamin: "Laki-laki", StatusPerkawinan: "Kawin",
			TempatLahir: "Kei Kecil", TanggalLahirRaw: "15/08/1980", Agama: "Islam",
			Pendidikan: "SLTA/Sederajat", Pekerjaan: "Petani", Kewarganegaraan: "WNI",
			StatusHubungan: "Kepala Keluarga", NIK: nik, NomorKK: kk,
			NamaAyah: "Ayah", NamaIbu: "Ibu",
		}
	}
	addr := func(r personRow, alamat string) personRow {
		r.Alamat = alamat
		r.Kelurahan = "Ohoi Contoh"
		r.Kecamatan = "Kei Kecil Timur Selatan"
		r.KabupatenKota = "Maluku Tenggara"
		r.Provinsi = "Maluku"
		return r
	}

	var rows []personRow

	// 1: ledger style — address repeated on every row of family A.
	rowA1 := addr(base("3271010101010001", "8102150101800001", "Budi Santoso"), "Ohoi Ngursoin")
	rowA1.RowNum = 2
	rowA2 := addr(base("3271010101010001", "8102150101800002", "Ratna Dewi"), "Ohoi Ngursoin")
	rowA2.RowNum = 3
	rows = append(rows, rowA1, rowA2)

	// 2: KK-card style — address only on family B's first row.
	rowB1 := addr(base("3271010101010002", "8102150101800003", "Joko Wibowo"), "Ohoi Letvuan")
	rowB1.RowNum = 4
	rowB2 := base("3271010101010002", "8102150101800004", "Maria Goreti")
	rowB2.RowNum = 5
	rows = append(rows, rowB1, rowB2)

	// 3: family C's second row repeats the address with a typo — non-fatal.
	rowC1 := addr(base("3271010101010003", "8102150101800005", "Andi Pratama"), "Ohoi Test")
	rowC1.RowNum = 6
	rowC2 := addr(base("3271010101010003", "8102150101800006", "Siti Aminah"), "Ohoi Test")
	rowC2.Kelurahan = "Ohoi Salah Ketik"
	rowC2.RowNum = 7
	rows = append(rows, rowC1, rowC2)

	// 4: family D has no address anywhere — whole group must fail.
	rowD1 := base("3271010101010004", "8102150101800007", "Fitri Wulandari")
	rowD1.RowNum = 8
	rows = append(rows, rowD1)

	// 5: family E already exists in this village — member inserts regardless.
	rowE1 := base("3271010101010005", "8102150101800008", "Ahmad Fauzi")
	rowE1.RowNum = 9
	rows = append(rows, rowE1)

	// 6: family F exists, but in a different village — must not attach.
	rowF1 := base("3271010101010006", "8102150101800009", "Dewi Lestari")
	rowF1.RowNum = 10
	rows = append(rows, rowF1)

	// 7a: duplicate NIK within the file.
	rowG1 := addr(base("3271010101010007", "8102150101800010", "John Smith"), "Ohoi Dup")
	rowG1.RowNum = 11
	rowG2 := addr(base("3271010101010008", "8102150101800010", "John Smith Duplikat"), "Ohoi Dup")
	rowG2.RowNum = 12
	rows = append(rows, rowG1, rowG2)

	// 7b: invalid enum value.
	rowH := addr(base("3271010101010009", "8102150101800011", "Ahmad Invalid"), "Ohoi Enum")
	rowH.JenisKelamin = "Pria"
	rowH.RowNum = 13
	rows = append(rows, rowH)

	// 7c: malformed date.
	rowI := addr(base("3271010101010010", "8102150101800012", "Budi Tanggal"), "Ohoi Tanggal")
	rowI.TanggalLahirRaw = "32-13-2020"
	rowI.RowNum = 14
	rows = append(rows, rowI)

	// 7d: missing required field (Nama Lengkap).
	rowJ := addr(base("3271010101010011", "8102150101800013", ""), "Ohoi Kosong")
	rowJ.RowNum = 15
	rows = append(rows, rowJ)

	// 8: blank Nama Ayah/Nama Ibu — must still insert (regression test).
	rowK := addr(base("3271010101010012", "8102150101800014", "Tanpa Orang Tua"), "Ohoi Yatim")
	rowK.NamaAyah = ""
	rowK.NamaIbu = ""
	rowK.RowNum = 16
	rows = append(rows, rowK)

	existingPersonNIKs := map[string]bool{}
	existingKKGlobal := map[string]bool{
		"3271010101010005": true, // family E: exists...
		"3271010101010006": true, // family F: exists...
	}
	existingKKInVillage := map[string]bool{
		"3271010101010005": true, // ...and belongs to this village
		// 3271010101010006 deliberately absent: belongs to another village
	}

	fcResolved, vResolved := s.resolvePersonRows(rows, existingPersonNIKs, existingKKGlobal, existingKKInVillage)

	fcByKK := map[string]fcResolution{}
	for _, r := range fcResolved {
		fcByKK[r.row.NIK] = r
	}
	vByNIK := map[string]villagerResolution{}
	for _, r := range vResolved {
		vByNIK[r.row.NIK] = r
	}

	check := func(t *testing.T, label, status string, want string) {
		t.Helper()
		if status != want {
			t.Errorf("%s: got status %q, want %q", label, status, want)
		}
	}

	// 1: ledger style — family + both members inserted.
	check(t, "family A", fcByKK["3271010101010001"].status, dtos.ImportStatusInserted)
	check(t, "Budi Santoso", vByNIK["8102150101800001"].status, dtos.ImportStatusInserted)
	check(t, "Ratna Dewi", vByNIK["8102150101800002"].status, dtos.ImportStatusInserted)

	// 2: card style — family created from first row, second row (blank
	// address) still inserts as a member.
	check(t, "family B", fcByKK["3271010101010002"].status, dtos.ImportStatusInserted)
	check(t, "Joko Wibowo", vByNIK["8102150101800003"].status, dtos.ImportStatusInserted)
	check(t, "Maria Goreti", vByNIK["8102150101800004"].status, dtos.ImportStatusInserted)

	// 3: mismatched repeat — still inserted, with a non-fatal note.
	check(t, "family C", fcByKK["3271010101010003"].status, dtos.ImportStatusInserted)
	check(t, "Siti Aminah", vByNIK["8102150101800006"].status, dtos.ImportStatusInserted)
	if vByNIK["8102150101800006"].reason == "" {
		t.Errorf("Siti Aminah: expected a non-fatal mismatch note, got none")
	}

	// 4: no address anywhere — family and its only member both fail.
	check(t, "family D", fcByKK["3271010101010004"].status, dtos.ImportStatusFailed)
	check(t, "Fitri Wulandari", vByNIK["8102150101800007"].status, dtos.ImportStatusFailed)

	// 5: already exists in this village — family skipped, member inserted.
	check(t, "family E", fcByKK["3271010101010005"].status, dtos.ImportStatusSkippedDuplicate)
	check(t, "Ahmad Fauzi", vByNIK["8102150101800008"].status, dtos.ImportStatusInserted)

	// 6: exists in another village — family and member both fail, never attach.
	check(t, "family F", fcByKK["3271010101010006"].status, dtos.ImportStatusFailed)
	check(t, "Dewi Lestari", vByNIK["8102150101800009"].status, dtos.ImportStatusFailed)

	// 7a: duplicate NIK in file — second occurrence fails.
	if got := len(vResolved); got == 0 {
		t.Fatalf("no villager resolutions produced")
	}
	var johnCount, johnFailed int
	for _, r := range vResolved {
		if r.row.NIK == "8102150101800010" {
			johnCount++
			if r.status == dtos.ImportStatusFailed {
				johnFailed++
			}
		}
	}
	if johnCount != 2 || johnFailed != 1 {
		t.Errorf("duplicate NIK 8102150101800010: got %d occurrences, %d failed; want 2 occurrences, 1 failed", johnCount, johnFailed)
	}

	// 7b-d: enum, date, required-field failures.
	check(t, "invalid Jenis Kelamin", vByNIK["8102150101800011"].status, dtos.ImportStatusFailed)
	check(t, "malformed date", vByNIK["8102150101800012"].status, dtos.ImportStatusFailed)
	check(t, "missing Nama Lengkap", vByNIK["8102150101800013"].status, dtos.ImportStatusFailed)

	// 8: blank Nama Ayah/Nama Ibu must NOT block insertion.
	check(t, "blank Nama Ayah/Ibu", vByNIK["8102150101800014"].status, dtos.ImportStatusInserted)
}
