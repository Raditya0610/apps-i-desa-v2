package services

import (
	"testing"

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

	fcRows, err := f.GetRows(importSheetFamilyCards)
	if err != nil {
		t.Fatalf("missing sheet %s: %v", importSheetFamilyCards, err)
	}
	if len(fcRows) < 1 || len(fcRows[0]) != len(importFamilyCardColumns) {
		t.Fatalf("unexpected family card header row: %v", fcRows)
	}

	vRows, err := f.GetRows(importSheetVillagers)
	if err != nil {
		t.Fatalf("missing sheet %s: %v", importSheetVillagers, err)
	}
	if len(vRows) < 1 || len(vRows[0]) != len(importVillagerColumns) {
		t.Fatalf("unexpected villager header row: %v", vRows)
	}

	if _, err := f.GetRows(importSheetGuide); err != nil {
		t.Fatalf("missing guide sheet: %v", err)
	}

	dvs, err := f.GetDataValidations(importSheetVillagers)
	if err != nil {
		t.Fatalf("GetDataValidations failed: %v", err)
	}
	if len(dvs) == 0 {
		t.Fatalf("expected data validations on %s, found none", importSheetVillagers)
	}
	t.Logf("found %d data validations on %s", len(dvs), importSheetVillagers)
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
	req := buildFamilyCardRequest(familyCardRow{NIK: "123"}) // too short, other required fields blank
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
