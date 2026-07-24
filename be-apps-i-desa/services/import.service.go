package services

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/models"
	"Apps-I_Desa_Backend/repositories"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"github.com/google/uuid"
	"github.com/xuri/excelize/v2"
)

type ImportService struct {
	familyCardRepo *repositories.FamilyCardRepository
	villagerRepo   *repositories.VillagerRepository
	validate       *validator.Validate
}

func NewImportService(
	familyCardRepo *repositories.FamilyCardRepository,
	villagerRepo *repositories.VillagerRepository,
) *ImportService {
	return &ImportService{
		familyCardRepo: familyCardRepo,
		villagerRepo:   villagerRepo,
		validate:       validator.New(),
	}
}

// ── Row shapes ───────────────────────────────────────────────────────────

// personRow is one row of the single "Data Penduduk" sheet: one person, plus
// the family-level fields that only need to be filled in on the first row of
// a given Nomor KK (see resolveFamilyGroup).
type personRow struct {
	RowNum int

	NamaLengkap      string
	JenisKelamin     string
	StatusPerkawinan string
	TempatLahir      string
	TanggalLahirRaw  string
	Agama            string
	Pendidikan       string
	Pekerjaan        string
	Kewarganegaraan  string
	StatusHubungan   string
	NIK              string
	NomorKK          string
	NamaAyah         string
	NamaIbu          string
	NomorPaspor      string
	NomorKitas       string

	// Family-level — only required on whichever row of a Nomor KK group ends
	// up supplying them (see hasCompleteFamilyFields).
	Alamat        string
	RT            string
	RW            string
	Kelurahan     string
	Kecamatan     string
	KabupatenKota string
	KodePos       string
	Provinsi      string
}

// familyFields is the family-level data resolved for one Nomor KK group,
// sourced from whichever row supplied complete address fields (or empty,
// keyed just by RowNum/NIK, when no row did).
type familyFields struct {
	RowNum        int
	NIK           string
	Address       string
	RT            string
	RW            string
	Kelurahan     string
	Kecamatan     string
	KabupatenKota string
	KodePos       string
	Provinsi      string
}

// resolution wraps a parsed row with the outcome decided during validation.
// Rows destined for insertion carry ImportStatusInserted provisionally until
// their family group's transaction actually commits — commitFamilyGroup flips
// this to Failed in place if the transaction does not succeed.
type fcResolution struct {
	row    familyFields
	status string
	reason string
}

type villagerResolution struct {
	row          personRow
	status       string
	reason       string
	tanggalLahir time.Time
}

// familyGroup is the unit of transactional work: one family card (if it is
// being inserted this upload) plus every member row that resolved cleanly and
// links to it. Grouping by Nomor KK — rather than one transaction for the
// whole file or one per row — is what lets a bad row in one family fail
// without rolling back every other family in the same upload.
type familyGroup struct {
	fc      *fcResolution
	members []*villagerResolution
}

// ── Field labels for validator-error translation ────────────────────────
// Two separate maps because the same DTO field name means a different thing
// depending on which struct it's validating: AddFamilyCardRequest.NIK is
// what the template calls "Nomor KK", while AddVillagerRequest.NIK is the
// person's own NIK.

var familyCardFieldLabels = map[string]string{
	"NIK": "Nomor KK", "Address": "Alamat Lengkap", "RT": "RT", "RW": "RW",
	"Kelurahan": "Kelurahan", "Kecamatan": "Kecamatan", "KabupatenKota": "Kabupaten/Kota",
	"KodePos": "Kode Pos", "Provinsi": "Provinsi",
}

var villagerFieldLabels = map[string]string{
	"NIK": "NIK", "NamaLengkap": "Nama Lengkap", "JenisKelamin": "Jenis Kelamin",
	"TempatLahir": "Tempat Lahir", "TanggalLahir": "Tanggal Lahir", "Agama": "Agama",
	"Pendidikan": "Pendidikan Terakhir", "Pekerjaan": "Pekerjaan",
	"StatusPerkawinan": "Status Perkawinan", "StatusHubungan": "Kedudukan Dalam Keluarga",
	"Kewarganegaraan": "Kewarganegaraan", "NamaAyah": "Nama Ayah", "NamaIbu": "Nama Ibu",
	"FamilyCardID": "Nomor KK",
}

// ── Entry point ──────────────────────────────────────────────────────────

// ProcessImport parses an uploaded workbook, validates every row against the
// same rules as the manual "Tambah KK/Penduduk" forms, and inserts what
// passes — one transaction per family group so a bad row in one family never
// rolls back another. Always returns a full row-by-row report; only
// structural problems (bad village context, unreadable file, missing sheet)
// produce an error instead of a report.
func (s *ImportService) ProcessImport(file interface {
	Read(p []byte) (n int, err error)
}, ctx *fiber.Ctx) (*dtos.ImportSummaryResponse, error) {
	villageIDStr, _ := ctx.Locals("village").(string)
	if villageIDStr == "" {
		log.Error("Village ID not found in context")
		return nil, errors.New("village ID is required")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("village ID is not valid")
	}

	wb, err := excelize.OpenReader(file)
	if err != nil {
		log.Error("Error opening uploaded workbook:", err)
		return nil, errors.New("file tidak valid atau bukan format Excel (.xlsx)")
	}
	defer wb.Close()

	rawRows, err := wb.GetRows(importSheetData)
	if err != nil {
		return nil, fmt.Errorf("sheet %q tidak ditemukan di file — gunakan template resmi", importSheetData)
	}

	rows := parsePersonRows(rawRows)

	existingKKGlobal, existingKKInVillage, err := s.existingFamilyCardNIKs(villageID, rows)
	if err != nil {
		return nil, errors.New("gagal memeriksa data Kartu Keluarga yang sudah ada")
	}
	existingPersonNIKs, err := s.existingVillagerNIKs(rows)
	if err != nil {
		return nil, errors.New("gagal memeriksa data penduduk yang sudah ada")
	}

	fcResolved, vResolved := s.resolvePersonRows(rows, existingPersonNIKs, existingKKGlobal, existingKKInVillage)

	groups := buildFamilyGroups(fcResolved, vResolved)
	for kk, g := range groups {
		s.commitFamilyGroup(villageID, kk, g)
	}

	return buildSummaryResponse(fcResolved, vResolved), nil
}

// ── Batch existence checks (2 queries total, no N+1) ────────────────────

// existingFamilyCardNIKs returns two views of Nomor KK existence:
//   - global: any Nomor KK that already exists anywhere in the system.
//     Intentionally not village-scoped — Nomor KK is meant to be nationally
//     unique, so a collision anywhere means this upload cannot create a new
//     family card with that number, regardless of which village holds it.
//   - inVillage: the subset of those that belong to the uploader's own
//     village — the only ones a person row may attach to as an existing
//     family. Without this distinction, a Nomor KK that happens to exist in
//     a different village would still let this upload's rows attach to it.
func (s *ImportService) existingFamilyCardNIKs(
	villageID uuid.UUID, rows []personRow,
) (global map[string]bool, inVillage map[string]bool, err error) {
	candidates := map[string]bool{}
	for _, r := range rows {
		if kk := strings.TrimSpace(r.NomorKK); kk != "" {
			candidates[kk] = true
		}
	}
	list := make([]string, 0, len(candidates))
	for k := range candidates {
		list = append(list, k)
	}

	globalExisting, err := s.familyCardRepo.GetExistingNIKs(list)
	if err != nil {
		return nil, nil, err
	}
	inVillageExisting, err := s.familyCardRepo.GetExistingNIKsInVillage(villageID, list)
	if err != nil {
		return nil, nil, err
	}

	return toSet(globalExisting), toSet(inVillageExisting), nil
}

func (s *ImportService) existingVillagerNIKs(rows []personRow) (map[string]bool, error) {
	candidates := map[string]bool{}
	for _, r := range rows {
		if r.NIK != "" {
			candidates[r.NIK] = true
		}
	}
	list := make([]string, 0, len(candidates))
	for k := range candidates {
		list = append(list, k)
	}
	existing, err := s.villagerRepo.GetExistingNIKs(list)
	if err != nil {
		return nil, err
	}
	return toSet(existing), nil
}

// ── Row resolution ───────────────────────────────────────────────────────

// resolvePersonRows validates every row's own person-level fields, resolves
// one family outcome per distinct Nomor KK group, and combines the two into
// a final per-row result: a row fails if its own fields are invalid, if it's
// a duplicate NIK within the file, or if the family group it belongs to
// could not be resolved.
func (s *ImportService) resolvePersonRows(
	rows []personRow,
	existingPersonNIKs, existingKKGlobal, existingKKInVillage map[string]bool,
) ([]fcResolution, []villagerResolution) {
	// Phase 1: per-row person-level validation, independent of family/group
	// concerns — a typo in one person's NIK has no bearing on whether their
	// family's address data is usable, and vice versa.
	type eval struct {
		dup          bool
		dupReason    string
		reasons      []string
		tanggalLahir time.Time
	}
	seenNIK := map[string]int{}
	evals := make([]eval, len(rows))
	for i, r := range rows {
		if firstIdx, dup := seenNIK[r.NIK]; dup {
			evals[i] = eval{
				dup:       true,
				dupReason: fmt.Sprintf("NIK duplikat dalam file (baris pertama: baris %d)", rows[firstIdx].RowNum),
			}
			continue
		}
		seenNIK[r.NIK] = i

		var reasons []string
		if reason := validateEnumOption("Jenis Kelamin", r.JenisKelamin, dtos.ImportJenisKelaminOptions); reason != "" {
			reasons = append(reasons, reason)
		}
		if reason := validateEnumOption("Status Perkawinan", r.StatusPerkawinan, dtos.ImportStatusPerkawinanOptions); reason != "" {
			reasons = append(reasons, reason)
		}
		if reason := validateEnumOption("Agama", r.Agama, dtos.ImportAgamaOptions); reason != "" {
			reasons = append(reasons, reason)
		}
		if reason := validateEnumOption("Pendidikan Terakhir", r.Pendidikan, dtos.ImportPendidikanOptions); reason != "" {
			reasons = append(reasons, reason)
		}
		if reason := validateEnumOption("Kedudukan Dalam Keluarga", r.StatusHubungan, dtos.ImportStatusHubunganOptions); reason != "" {
			reasons = append(reasons, reason)
		}
		if reason := validateEnumOption("Kewarganegaraan", r.Kewarganegaraan, dtos.ImportKewarganegaraanOptions); reason != "" {
			reasons = append(reasons, reason)
		}

		tanggalLahir, dateErr := parseTanggalLahir(r.TanggalLahirRaw)
		dateStrForValidation := "0001-01-01" // placeholder so the shared "required" tag passes; the real problem is reported below
		if dateErr != nil {
			reasons = append(reasons, "Tanggal Lahir tidak valid: "+dateErr.Error())
		} else {
			dateStrForValidation = tanggalLahir.Format("2006-01-02")
		}

		req := buildVillagerRequest(r, dateStrForValidation)
		if err := s.validate.Struct(&req); err != nil {
			reasons = append(reasons, translateValidationErrors(err, villagerFieldLabels))
		}

		evals[i] = eval{reasons: reasons, tanggalLahir: tanggalLahir}
	}

	// Phase 2: one family resolution per distinct Nomor KK. Rows with a
	// blank Nomor KK are excluded from grouping — they already fail on their
	// own via the "required" check on FamilyCardID above.
	groupRows := map[string][]personRow{}
	var groupOrder []string
	for _, r := range rows {
		kk := strings.TrimSpace(r.NomorKK)
		if kk == "" {
			continue
		}
		if _, seen := groupRows[kk]; !seen {
			groupOrder = append(groupOrder, kk)
		}
		groupRows[kk] = append(groupRows[kk], r)
	}

	var fcResolved []fcResolution
	familyOutcome := make(map[string]fcResolution, len(groupOrder))
	for _, kk := range groupOrder {
		res := s.resolveFamilyGroup(kk, groupRows[kk], existingKKGlobal, existingKKInVillage)
		familyOutcome[kk] = res
		fcResolved = append(fcResolved, res)
	}

	// Phase 3: combine. A non-fatal note (not a failure) is attached when a
	// later row of the same family repeats an address field that disagrees
	// with the row actually used to create it — most likely a typo, not
	// something that should block that row from being inserted.
	var vResolved []villagerResolution
	for i, r := range rows {
		e := evals[i]
		if e.dup {
			vResolved = append(vResolved, villagerResolution{row: r, status: dtos.ImportStatusFailed, reason: e.dupReason})
			continue
		}

		reasons := append([]string{}, e.reasons...)
		var notes []string

		kk := strings.TrimSpace(r.NomorKK)
		if fam, hasFamily := familyOutcome[kk]; hasFamily {
			if fam.status == dtos.ImportStatusFailed {
				reasons = append(reasons, "Kartu Keluarga terkait gagal diproses: "+fam.reason)
			} else if fam.status == dtos.ImportStatusInserted && r.RowNum != fam.row.RowNum {
				if mismatch := describeFamilyFieldMismatch(r, fam.row); mismatch != "" {
					notes = append(notes, mismatch)
				}
			}
		}
		// hasFamily is false only when kk == "" — the FamilyCardID
		// "required" validator error already explains that case.

		if len(reasons) > 0 {
			vResolved = append(vResolved, villagerResolution{row: r, status: dtos.ImportStatusFailed, reason: strings.Join(reasons, "; ")})
			continue
		}

		if existingPersonNIKs[r.NIK] {
			reason := "NIK sudah terdaftar di sistem"
			if len(notes) > 0 {
				reason += "; " + strings.Join(notes, "; ")
			}
			vResolved = append(vResolved, villagerResolution{row: r, status: dtos.ImportStatusSkippedDuplicate, reason: reason})
			continue
		}

		vResolved = append(vResolved, villagerResolution{
			row: r, status: dtos.ImportStatusInserted, tanggalLahir: e.tanggalLahir,
			reason: strings.Join(notes, "; "),
		})
	}

	return fcResolved, vResolved
}

// resolveFamilyGroup decides what happens to one Nomor KK: already this
// village's (skip, members may attach), already exists but belongs to
// another village (fail — cannot create it, cannot attach to it either),
// or new (create it from whichever row in the group supplied complete,
// valid address fields).
func (s *ImportService) resolveFamilyGroup(
	nomorKK string, rows []personRow, existingKKGlobal, existingKKInVillage map[string]bool,
) fcResolution {
	firstRowNum := rows[0].RowNum

	type kkFormatCheck struct {
		NIK string `validate:"required,len=16,numeric"`
	}
	if err := s.validate.Struct(&kkFormatCheck{NIK: nomorKK}); err != nil {
		return fcResolution{
			row:    familyFields{RowNum: firstRowNum, NIK: nomorKK},
			status: dtos.ImportStatusFailed,
			reason: translateValidationErrors(err, familyCardFieldLabels),
		}
	}

	if existingKKInVillage[nomorKK] {
		return fcResolution{
			row:    familyFields{RowNum: firstRowNum, NIK: nomorKK},
			status: dtos.ImportStatusSkippedDuplicate,
			reason: "Nomor KK sudah terdaftar di sistem",
		}
	}

	if existingKKGlobal[nomorKK] {
		return fcResolution{
			row:    familyFields{RowNum: firstRowNum, NIK: nomorKK},
			status: dtos.ImportStatusFailed,
			reason: "Nomor KK ini sudah terdaftar di sistem tetapi bukan milik desa Anda",
		}
	}

	for _, r := range rows {
		if !hasCompleteFamilyFields(r) {
			continue
		}
		fields := familyFieldsFromRow(r, nomorKK)
		req := buildFamilyCardRequest(fields)
		if err := s.validate.Struct(&req); err != nil {
			return fcResolution{
				row: fields, status: dtos.ImportStatusFailed,
				reason: translateValidationErrors(err, familyCardFieldLabels),
			}
		}
		return fcResolution{row: fields, status: dtos.ImportStatusInserted}
	}

	return fcResolution{
		row:    familyFields{RowNum: firstRowNum, NIK: nomorKK},
		status: dtos.ImportStatusFailed,
		reason: "Nomor KK ini belum pernah dibuat — isi Alamat Lengkap, Kelurahan, Kecamatan, Kabupaten/Kota, dan Provinsi pada salah satu baris penduduk untuk Nomor KK ini",
	}
}

// hasCompleteFamilyFields reports whether a row carries enough family-level
// data to create a family_cards row from. RT/RW/Kode Pos are deliberately
// excluded — those stay optional even on the row that supplies the rest.
func hasCompleteFamilyFields(r personRow) bool {
	return r.Alamat != "" && r.Kelurahan != "" && r.Kecamatan != "" && r.KabupatenKota != "" && r.Provinsi != ""
}

func familyFieldsFromRow(r personRow, nomorKK string) familyFields {
	return familyFields{
		RowNum: r.RowNum, NIK: nomorKK, Address: r.Alamat,
		RT: r.RT, RW: r.RW, Kelurahan: r.Kelurahan, Kecamatan: r.Kecamatan,
		KabupatenKota: r.KabupatenKota, KodePos: r.KodePos, Provinsi: r.Provinsi,
	}
}

func describeFamilyFieldMismatch(r personRow, source familyFields) string {
	var diffs []string
	check := func(label, got, want string) {
		if got != "" && got != want {
			diffs = append(diffs, label)
		}
	}
	check("Alamat Lengkap", r.Alamat, source.Address)
	check("RT", r.RT, source.RT)
	check("RW", r.RW, source.RW)
	check("Kelurahan", r.Kelurahan, source.Kelurahan)
	check("Kecamatan", r.Kecamatan, source.Kecamatan)
	check("Kabupaten/Kota", r.KabupatenKota, source.KabupatenKota)
	check("Kode Pos", r.KodePos, source.KodePos)
	check("Provinsi", r.Provinsi, source.Provinsi)
	if len(diffs) == 0 {
		return ""
	}
	return fmt.Sprintf(
		"Catatan: %s berbeda dari baris pertama Nomor KK ini (baris %d) — data yang dipakai adalah baris pertama",
		strings.Join(diffs, ", "), source.RowNum,
	)
}

// ── Transactional insert, grouped per family ────────────────────────────

func buildFamilyGroups(fcResolved []fcResolution, vResolved []villagerResolution) map[string]*familyGroup {
	groups := map[string]*familyGroup{}

	for i := range fcResolved {
		if fcResolved[i].status != dtos.ImportStatusInserted {
			continue
		}
		kk := fcResolved[i].row.NIK
		g := groups[kk]
		if g == nil {
			g = &familyGroup{}
			groups[kk] = g
		}
		g.fc = &fcResolved[i]
	}

	for i := range vResolved {
		if vResolved[i].status != dtos.ImportStatusInserted {
			continue
		}
		kk := strings.TrimSpace(vResolved[i].row.NomorKK)
		g := groups[kk]
		if g == nil {
			g = &familyGroup{}
			groups[kk] = g
		}
		g.members = append(g.members, &vResolved[i])
	}

	return groups
}

// commitFamilyGroup inserts one family card (if new) and its eligible
// members inside a single transaction, mutating the resolution pointers in
// place with the final outcome. If any insert fails, every row in the group
// is flipped to Failed rather than attempting to salvage partial inserts —
// once a statement errors inside a Postgres transaction, later statements in
// the same transaction cannot succeed anyway.
func (s *ImportService) commitFamilyGroup(villageID uuid.UUID, kk string, g *familyGroup) {
	tx := s.familyCardRepo.BeginTransaction()
	defer tx.Rollback()

	failed := false
	failReason := ""

	if g.fc != nil {
		r := g.fc.row
		model := &models.FamilyCard{
			NIK:           r.NIK,
			Alamat:        r.Address,
			RT:            orDefault(r.RT, "0"),
			RW:            orDefault(r.RW, "0"),
			Kelurahan:     r.Kelurahan,
			Kecamatan:     r.Kecamatan,
			KabupatenKota: r.KabupatenKota,
			KodePos:       r.KodePos,
			Provinsi:      r.Provinsi,
			VillageID:     villageID,
		}
		if err := s.familyCardRepo.CreateWithTx(tx, model); err != nil {
			log.Errorf("import: failed to insert family card %s: %v", r.NIK, err)
			failed = true
			failReason = "Gagal menyimpan Kartu Keluarga ke database"
		}
	}

	for _, m := range g.members {
		if failed {
			break
		}
		r := m.row
		model := &models.Villager{
			NIK:              r.NIK,
			NamaLengkap:      r.NamaLengkap,
			JenisKelamin:     r.JenisKelamin,
			TempatLahir:      r.TempatLahir,
			TanggalLahir:     m.tanggalLahir,
			Agama:            r.Agama,
			Pendidikan:       r.Pendidikan,
			Pekerjaan:        r.Pekerjaan,
			StatusPerkawinan: r.StatusPerkawinan,
			StatusHubungan:   r.StatusHubungan,
			Kewarganegaraan:  r.Kewarganegaraan,
			NamaAyah:         r.NamaAyah,
			NamaIbu:          r.NamaIbu,
			VillageID:        villageID,
			FamilyCardID:     kk,
		}
		if r.NomorPaspor != "" {
			v := r.NomorPaspor
			model.NomorPaspor = &v
		}
		if r.NomorKitas != "" {
			v := r.NomorKitas
			model.NomorKitas = &v
		}

		if err := s.villagerRepo.CreateVillagerWithTx(tx, model); err != nil {
			log.Errorf("import: failed to insert villager %s: %v", r.NIK, err)
			failed = true
			failReason = "Gagal menyimpan data penduduk ke database"
		}
	}

	if !failed {
		if err := tx.Commit().Error; err != nil {
			log.Errorf("import: failed to commit family group %s: %v", kk, err)
			failed = true
			failReason = "Gagal menyimpan grup keluarga ke database"
		}
	}

	if failed {
		if g.fc != nil {
			g.fc.status = dtos.ImportStatusFailed
			g.fc.reason = failReason
		}
		for _, m := range g.members {
			m.status = dtos.ImportStatusFailed
			m.reason = failReason
		}
	}
}

// ── Summary assembly ─────────────────────────────────────────────────────

func buildSummaryResponse(fcResolved []fcResolution, vResolved []villagerResolution) *dtos.ImportSummaryResponse {
	var summary dtos.ImportSummary
	var results []dtos.ImportRowResult

	for _, r := range fcResolved {
		results = append(results, dtos.ImportRowResult{
			Sheet: importSheetData, Row: r.row.RowNum, Identifier: r.row.NIK,
			Status: r.status, Reason: r.reason,
		})
		summary.FamilyCardsTotal++
		switch r.status {
		case dtos.ImportStatusInserted:
			summary.FamilyCardsInserted++
		case dtos.ImportStatusSkippedDuplicate:
			summary.FamilyCardsSkipped++
		case dtos.ImportStatusFailed:
			summary.FamilyCardsFailed++
		}
	}

	for _, r := range vResolved {
		results = append(results, dtos.ImportRowResult{
			Sheet: importSheetData, Row: r.row.RowNum, Identifier: r.row.NIK,
			Status: r.status, Reason: r.reason,
		})
		summary.VillagersTotal++
		switch r.status {
		case dtos.ImportStatusInserted:
			summary.VillagersInserted++
		case dtos.ImportStatusSkippedDuplicate:
			summary.VillagersSkipped++
		case dtos.ImportStatusFailed:
			summary.VillagersFailed++
		}
	}

	return &dtos.ImportSummaryResponse{Summary: summary, Results: results}
}

// ── Parsing helpers ──────────────────────────────────────────────────────

// Column indices (0-based) into importDataColumns. Three positions —
// Nomor Urut (0), Dapat Membaca Huruf (9), Ket (15) — are deliberately
// skipped: they exist in the template only so a row from the Buku Induk
// Penduduk ledger can be pasted in one motion (see importDataIgnoredColumns
// in import_template.service.go).
func parsePersonRows(rows [][]string) []personRow {
	var out []personRow
	for i, row := range rows {
		rowNum := i + 1
		if rowNum == 1 || isRowBlank(row) {
			continue
		}
		out = append(out, personRow{
			RowNum:           rowNum,
			NamaLengkap:      strings.TrimSpace(cell(row, 1)),
			JenisKelamin:     strings.TrimSpace(cell(row, 2)),
			StatusPerkawinan: strings.TrimSpace(cell(row, 3)),
			TempatLahir:      strings.TrimSpace(cell(row, 4)),
			TanggalLahirRaw:  strings.TrimSpace(cell(row, 5)),
			Agama:            strings.TrimSpace(cell(row, 6)),
			Pendidikan:       strings.TrimSpace(cell(row, 7)),
			Pekerjaan:        strings.TrimSpace(cell(row, 8)),
			Kewarganegaraan:  strings.TrimSpace(cell(row, 10)),
			Alamat:           strings.TrimSpace(cell(row, 11)),
			StatusHubungan:   strings.TrimSpace(cell(row, 12)),
			NIK:              strings.TrimSpace(cell(row, 13)),
			NomorKK:          strings.TrimSpace(cell(row, 14)),
			RT:               strings.TrimSpace(cell(row, 16)),
			RW:               strings.TrimSpace(cell(row, 17)),
			Kelurahan:        strings.TrimSpace(cell(row, 18)),
			Kecamatan:        strings.TrimSpace(cell(row, 19)),
			KabupatenKota:    strings.TrimSpace(cell(row, 20)),
			KodePos:          strings.TrimSpace(cell(row, 21)),
			Provinsi:         strings.TrimSpace(cell(row, 22)),
			NamaAyah:         strings.TrimSpace(cell(row, 23)),
			NamaIbu:          strings.TrimSpace(cell(row, 24)),
			NomorPaspor:      strings.TrimSpace(cell(row, 25)),
			NomorKitas:       strings.TrimSpace(cell(row, 26)),
		})
	}
	return out
}

func cell(row []string, idx int) string {
	if idx >= len(row) {
		return ""
	}
	return row[idx]
}

func isRowBlank(row []string) bool {
	for _, c := range row {
		if strings.TrimSpace(c) != "" {
			return false
		}
	}
	return true
}

// villagerDateLayouts covers the template's own dd/mm/yyyy display format,
// the manual form's ISO format, and a couple of common typing variants.
var villagerDateLayouts = []string{"02/01/2006", "2006-01-02", "02-01-2006", "2/1/2006", "1/2/2006"}

// parseTanggalLahir accepts the formatted date text Excel produces for a
// correctly-entered date, and falls back to interpreting a raw Excel serial
// number for values injected directly into a cell (bypassing Excel's own
// date picker) — this is what lets the backend validate dates independently
// of whatever the spreadsheet application already enforced.
func parseTanggalLahir(raw string) (time.Time, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return time.Time{}, errors.New("kosong")
	}
	for _, layout := range villagerDateLayouts {
		if t, err := time.Parse(layout, raw); err == nil {
			return t, nil
		}
	}
	if serial, err := strconv.ParseFloat(raw, 64); err == nil && serial > 0 {
		return excelSerialToTime(serial), nil
	}
	return time.Time{}, fmt.Errorf("format tidak dikenali (%q)", raw)
}

// excelSerialToTime replicates Excel's day-count-from-1899-12-30 convention
// (including its well-known fictitious-1900-leap-year quirk) since excelize
// does not expose a public serial-to-time conversion helper.
func excelSerialToTime(serial float64) time.Time {
	epoch := time.Date(1899, time.December, 30, 0, 0, 0, 0, time.UTC)
	return epoch.Add(time.Duration(serial * float64(24*time.Hour)))
}

func validateEnumOption(label, value string, options []string) string {
	for _, o := range options {
		if o == value {
			return ""
		}
	}
	return fmt.Sprintf("%s harus salah satu dari: %s (nilai saat ini: %q)", label, strings.Join(options, ", "), value)
}

func buildFamilyCardRequest(fields familyFields) dtos.AddFamilyCardRequest {
	// RT/RW/KodePos may legitimately be blank (villages often only have the
	// Buku Induk Penduduk, not the physical KK certificate with RT/RW/postal
	// data). Placeholders here only satisfy the shared "required" tag so the
	// rest of the struct's validation still runs; the real default ('0' for
	// RT/RW, '' for KodePos) is applied at insert time in commitFamilyGroup.
	rt, rw, kodePos := fields.RT, fields.RW, fields.KodePos
	if rt == "" {
		rt = "0"
	}
	if rw == "" {
		rw = "0"
	}
	if kodePos == "" {
		kodePos = "0"
	}
	return dtos.AddFamilyCardRequest{
		NIK: fields.NIK, Address: fields.Address, RT: rt, RW: rw,
		Kelurahan: fields.Kelurahan, Kecamatan: fields.Kecamatan,
		KabupatenKota: fields.KabupatenKota, KodePos: kodePos, Provinsi: fields.Provinsi,
	}
}

func buildVillagerRequest(r personRow, tanggalLahirStr string) dtos.AddVillagerRequest {
	var nomorPaspor, nomorKitas *string
	if r.NomorPaspor != "" {
		v := r.NomorPaspor
		nomorPaspor = &v
	}
	if r.NomorKitas != "" {
		v := r.NomorKitas
		nomorKitas = &v
	}
	return dtos.AddVillagerRequest{
		NIK: r.NIK, NamaLengkap: r.NamaLengkap, JenisKelamin: r.JenisKelamin,
		TempatLahir: r.TempatLahir, TanggalLahir: tanggalLahirStr, Agama: r.Agama,
		Pendidikan: r.Pendidikan, Pekerjaan: r.Pekerjaan, StatusPerkawinan: r.StatusPerkawinan,
		StatusHubungan: r.StatusHubungan, Kewarganegaraan: r.Kewarganegaraan,
		NomorPaspor: nomorPaspor, NomorKitas: nomorKitas,
		NamaAyah: r.NamaAyah, NamaIbu: r.NamaIbu, FamilyCardID: strings.TrimSpace(r.NomorKK),
	}
}

func orDefault(v, def string) string {
	if v == "" {
		return def
	}
	return v
}

func toSet(list []string) map[string]bool {
	set := make(map[string]bool, len(list))
	for _, v := range list {
		set[v] = true
	}
	return set
}

// ── Validator error translation ─────────────────────────────────────────

func translateValidationErrors(err error, labels map[string]string) string {
	var ve validator.ValidationErrors
	if !errors.As(err, &ve) {
		return err.Error()
	}
	parts := make([]string, 0, len(ve))
	for _, fe := range ve {
		parts = append(parts, translateFieldError(fe, labels))
	}
	return strings.Join(parts, "; ")
}

func translateFieldError(fe validator.FieldError, labels map[string]string) string {
	label := labels[fe.Field()]
	if label == "" {
		label = fe.Field()
	}
	switch fe.Tag() {
	case "required":
		return fmt.Sprintf("%s wajib diisi", label)
	case "len":
		return fmt.Sprintf("%s harus %s karakter", label, fe.Param())
	case "numeric":
		return fmt.Sprintf("%s harus berupa angka", label)
	default:
		return fmt.Sprintf("%s tidak valid", label)
	}
}
