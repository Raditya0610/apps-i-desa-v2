package services

import (
	"errors"
	"sort"
	"strings"
	"sync"

	"Apps-I_Desa_Backend/dtos"
	"Apps-I_Desa_Backend/repositories"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"github.com/google/uuid"
)

// pekerjaanBreakdownTopN caps the freeform Pekerjaan breakdown to the
// largest groups, with the remainder folded into "Lainnya" — without a
// dropdown, a village can easily have 30+ distinct spellings/job titles,
// which would make the chart unreadable.
const pekerjaanBreakdownTopN = 8

// ageGroupBuckets defines the age-range boundaries for the dashboard's Usia
// breakdown, youngest to oldest. MaxYears is inclusive; the last bucket
// (MaxYears -1) has no upper bound. Single source of truth for the buckets —
// adjust here only, nothing else needs to change.
var ageGroupBuckets = []struct {
	Label    string
	MaxYears int
}{
	{"0-5 Tahun", 5},
	{"6-12 Tahun", 12},
	{"13-18 Tahun", 18},
	{"19-30 Tahun", 30},
	{"31-45 Tahun", 45},
	{"46-60 Tahun", 60},
	{"60+ Tahun", -1},
}

type DashboardService struct {
	villagerRepo   *repositories.VillagerRepository
	familyCardRepo *repositories.FamilyCardRepository
}

func NewDashboardService(
	villagerRepo *repositories.VillagerRepository,
	familyCardRepo *repositories.FamilyCardRepository,
) *DashboardService {
	return &DashboardService{
		villagerRepo:   villagerRepo,
		familyCardRepo: familyCardRepo,
	}
}

func (s *DashboardService) GetDashboardData(ctx *fiber.Ctx) (*dtos.GetDashboardResponse, error) {
	// comma-ok: a token without a village claim yields "" here rather than
	// panicking on the assertion; the empty check below turns it into a clean error.
	villageIDStr, _ := ctx.Locals("village").(string)
	if villageIDStr == "" {
		log.Error("village ID is empty")
		return nil, errors.New("village ID is empty")
	}
	villageID, err := uuid.Parse(villageIDStr)
	if err != nil {
		log.Error("Error parsing village ID:", err)
		return nil, errors.New("invalid village ID format")
	}

	// Create channels to receive results
	type result struct {
		value interface{}
		err   error
	}

	// Create channels for each operation
	familyCardsCh := make(chan result, 1)
	rtCh := make(chan result, 1)
	rwCh := make(chan result, 1)
	kelurahanCh := make(chan result, 1)
	kecamatanCh := make(chan result, 1)
	villagersCh := make(chan result, 1)
	maleVillagersCh := make(chan result, 1)
	femaleVillagersCh := make(chan result, 1)
	averageAgeCh := make(chan result, 1)
	kepalaKeluargaCh := make(chan result, 1)
	pendidikanCh := make(chan result, 1)
	pekerjaanCh := make(chan result, 1)
	agesCh := make(chan result, 1)

	var wg sync.WaitGroup

	// Launch goroutines for family card operations
	wg.Add(5)
	go func() {
		defer wg.Done()
		count, err := s.familyCardRepo.CountAllFamilyCardByVillageID(&villageID)
		familyCardsCh <- result{count, err}
	}()

	go func() {
		defer wg.Done()
		count, err := s.familyCardRepo.CountDistinctRT(&villageID)
		rtCh <- result{count, err}
	}()

	go func() {
		defer wg.Done()
		count, err := s.familyCardRepo.CountDistinctRW(&villageID)
		rwCh <- result{count, err}
	}()

	go func() {
		defer wg.Done()
		count, err := s.familyCardRepo.CountDistinctKelurahan(&villageID)
		kelurahanCh <- result{count, err}
	}()

	go func() {
		defer wg.Done()
		count, err := s.familyCardRepo.CountDistinctKecamatan(&villageID)
		kecamatanCh <- result{count, err}
	}()

	// Launch goroutines for villager operations
	wg.Add(5)
	go func() {
		defer wg.Done()
		count, err := s.villagerRepo.CountAllVillagerByVillageID(&villageID)
		villagersCh <- result{count, err}
	}()

	go func() {
		defer wg.Done()
		count, err := s.villagerRepo.CountAllLakiLakiVillager(&villageID)
		maleVillagersCh <- result{count, err}
	}()

	// Counted, not derived as total-minus-male: that treated every row failing an
	// exact "Laki-laki" match — including blanks and unrecognised values — as
	// female.
	go func() {
		defer wg.Done()
		count, err := s.villagerRepo.CountAllPerempuanVillager(&villageID)
		femaleVillagersCh <- result{count, err}
	}()

	go func() {
		defer wg.Done()
		avg, err := s.villagerRepo.GetAverageAge(&villageID)
		averageAgeCh <- result{avg, err}
	}()

	go func() {
		defer wg.Done()
		count, err := s.villagerRepo.CountAllKepalaKeluarga(&villageID)
		kepalaKeluargaCh <- result{count, err}
	}()

	wg.Add(3)
	go func() {
		defer wg.Done()
		items, err := s.villagerRepo.CountByPendidikan(&villageID)
		pendidikanCh <- result{items, err}
	}()

	go func() {
		defer wg.Done()
		items, err := s.villagerRepo.CountByPekerjaan(&villageID)
		pekerjaanCh <- result{items, err}
	}()

	go func() {
		defer wg.Done()
		ages, err := s.villagerRepo.GetAllAges(&villageID)
		agesCh <- result{ages, err}
	}()

	// Wait for all goroutines to complete
	wg.Wait()

	// Collect results and check for errors
	familyCardsRes := <-familyCardsCh
	if familyCardsRes.err != nil {
		log.Error("Error counting family cards:", familyCardsRes.err)
		return nil, errors.New("error counting family cards")
	}
	countFamilyCards := familyCardsRes.value.(int64)

	rtRes := <-rtCh
	if rtRes.err != nil {
		log.Error("Error counting distinct RT:", rtRes.err)
		return nil, errors.New("error counting distinct RT")
	}
	countDistinctRT := rtRes.value.(int64)

	rwRes := <-rwCh
	if rwRes.err != nil {
		log.Error("Error counting distinct RW:", rwRes.err)
		return nil, errors.New("error counting distinct RW")
	}
	countDistinctRW := rwRes.value.(int64)

	kelurahanRes := <-kelurahanCh
	if kelurahanRes.err != nil {
		log.Error("Error counting distinct Kelurahan:", kelurahanRes.err)
		return nil, errors.New("error counting distinct Kelurahan")
	}
	countDistinctKelurahan := kelurahanRes.value.(int64)

	kecamatanRes := <-kecamatanCh
	if kecamatanRes.err != nil {
		log.Error("Error counting distinct Kecamatan:", kecamatanRes.err)
		return nil, errors.New("error counting distinct Kecamatan")
	}
	countDistinctKecamatan := kecamatanRes.value.(int64)

	villagersRes := <-villagersCh
	if villagersRes.err != nil {
		log.Error("Error counting villagers:", villagersRes.err)
		return nil, errors.New("error counting villagers")
	}
	countVillagers := villagersRes.value.(int64)

	maleVillagersRes := <-maleVillagersCh
	if maleVillagersRes.err != nil {
		log.Error("Error counting male villagers:", maleVillagersRes.err)
		return nil, errors.New("error counting male villagers")
	}
	countMaleVillagers := maleVillagersRes.value.(int64)

	femaleVillagersRes := <-femaleVillagersCh
	if femaleVillagersRes.err != nil {
		log.Error("Error counting female villagers:", femaleVillagersRes.err)
		return nil, errors.New("error counting female villagers")
	}
	countFemaleVillagers := femaleVillagersRes.value.(int64)

	averageAgeRes := <-averageAgeCh
	if averageAgeRes.err != nil {
		log.Error("Error getting average age:", averageAgeRes.err)
		return nil, errors.New("error getting average age")
	}
	countAverageAge := averageAgeRes.value.(float32)

	kepalaKeluargaRes := <-kepalaKeluargaCh
	if kepalaKeluargaRes.err != nil {
		log.Error("Error counting kepala keluarga:", kepalaKeluargaRes.err)
		return nil, errors.New("error counting kepala keluarga")
	}
	countKepalaKeluarga := kepalaKeluargaRes.value.(int64)

	pendidikanRes := <-pendidikanCh
	if pendidikanRes.err != nil {
		log.Error("Error counting pendidikan breakdown:", pendidikanRes.err)
		return nil, errors.New("error counting pendidikan breakdown")
	}
	pendidikanBreakdown := buildPendidikanBreakdown(pendidikanRes.value.([]dtos.LabeledCount))

	pekerjaanRes := <-pekerjaanCh
	if pekerjaanRes.err != nil {
		log.Error("Error counting pekerjaan breakdown:", pekerjaanRes.err)
		return nil, errors.New("error counting pekerjaan breakdown")
	}
	pekerjaanBreakdown := buildPekerjaanBreakdown(pekerjaanRes.value.([]dtos.LabeledCount))

	agesRes := <-agesCh
	if agesRes.err != nil {
		log.Error("Error getting ages for usia breakdown:", agesRes.err)
		return nil, errors.New("error getting ages for usia breakdown")
	}
	usiaBreakdown := buildUsiaBreakdown(agesRes.value.([]int))

	// Guarded: dividing by zero residents yields +Inf, and encoding/json refuses
	// to marshal Inf — an empty village would fail the whole dashboard request
	// rather than return zeros.
	var rerataKeluarga float32
	if countVillagers > 0 {
		rerataKeluarga = float32(countFamilyCards) / float32(countVillagers)
	}

	return &dtos.GetDashboardResponse{
		TotalKeluarga:       int32(countFamilyCards),
		TotalPenduduk:       int32(countVillagers),
		RerataKeluarga:      rerataKeluarga,
		TotalLakiLaki:       int32(countMaleVillagers),
		TotalPerempuan:      int32(countFemaleVillagers),
		TotalKepalaKeluarga: int32(countKepalaKeluarga),
		RerataUmur:          countAverageAge,
		TotalRT:             int32(countDistinctRT),
		TotalRW:             int32(countDistinctRW),
		TotalKelurahan:      int32(countDistinctKelurahan),
		TotalKecamatan:      int32(countDistinctKecamatan),
		PendidikanBreakdown: pendidikanBreakdown,
		PekerjaanBreakdown:  pekerjaanBreakdown,
		UsiaBreakdown:       usiaBreakdown,
	}, nil
}

// normalizeLabel maps blank/placeholder values (raw SQL imports have used
// both "" and "-" for missing data) to one consistent bucket, so they don't
// silently fragment into multiple near-identical rows in the breakdown.
func normalizeLabel(label string) string {
	label = strings.TrimSpace(label)
	if label == "" || label == "-" {
		return "Tidak Diketahui"
	}
	return label
}

// legacyPendidikanAliases maps Pendidikan values seen in real data that
// predate (or were imported outside of) the dtos.ImportPendidikanOptions
// validation, onto their canonical equivalent. Without this, e.g. "Belum
// Sekolah" and "Tidak/Belum Sekolah" show as two separate, undercounted
// breakdown rows for what is the same education level.
//
// Only mappings with an unambiguous canonical target are listed here.
// Values found in production data that were deliberately left out because
// the correct target isn't clear from the string alone — do not add them
// without confirming with real records:
//   - "SD/Sederajat": doesn't say whether school was completed, so it's
//     unclear whether it means "Tamat SD/Sederajat" or "Belum Tamat
//     SD/Sederajat".
//   - "Diploma IV/Strata 2": mixes a Diploma IV (S1-level) label with
//     "Strata 2" (S2/Master's level) — likely a data-entry mix-up, but
//     which field is the mistake isn't clear.
var legacyPendidikanAliases = map[string]string{
	"Belum Sekolah":       "Tidak/Belum Sekolah",
	"Belum Tamat SD":      "Belum Tamat SD/Sederajat",
	"Diploma IV/Strata 1": "Diploma IV/Strata I",
	"Diploma IV/S1":       "Diploma IV/Strata I",
	"Diploma III":         "Akademi/Diploma III/Sarjana Muda",
}

func normalizePendidikanLabel(label string) string {
	label = normalizeLabel(label)
	if canonical, ok := legacyPendidikanAliases[label]; ok {
		return canonical
	}
	return label
}

// mergeLabeledCounts applies normalize to every label and folds duplicates
// that collapse onto the same normalized label into a single summed entry,
// preserving first-seen order.
func mergeLabeledCounts(items []dtos.LabeledCount, normalize func(string) string) []dtos.LabeledCount {
	totals := make(map[string]int64, len(items))
	var order []string
	for _, it := range items {
		label := normalize(it.Label)
		if _, seen := totals[label]; !seen {
			order = append(order, label)
		}
		totals[label] += it.Total
	}
	merged := make([]dtos.LabeledCount, len(order))
	for i, label := range order {
		merged[i] = dtos.LabeledCount{Label: label, Total: totals[label]}
	}
	return merged
}

// buildPendidikanBreakdown orders by education level (matching
// ImportPendidikanOptions' low-to-high progression) rather than by count, so
// the chart reads as a progression instead of a jumbled ranking. Legacy
// values that don't match any known category (older manual entries predate
// the dropdown) sort after all known ones, largest first.
func buildPendidikanBreakdown(raw []dtos.LabeledCount) []dtos.LabeledCount {
	items := mergeLabeledCounts(raw, normalizePendidikanLabel)

	rank := make(map[string]int, len(dtos.ImportPendidikanOptions))
	for i, v := range dtos.ImportPendidikanOptions {
		rank[v] = i
	}

	sort.SliceStable(items, func(i, j int) bool {
		ri, iKnown := rank[items[i].Label]
		rj, jKnown := rank[items[j].Label]
		if iKnown && jKnown {
			return ri < rj
		}
		if iKnown != jKnown {
			return iKnown
		}
		return items[i].Total > items[j].Total
	})

	return items
}

// buildPekerjaanBreakdown orders by count descending — Pekerjaan is free
// text with no fixed category list — and caps the result at
// pekerjaanBreakdownTopN, folding the remainder into a "Lainnya" bucket so a
// village with many distinct job titles still gets a readable chart.
func buildPekerjaanBreakdown(raw []dtos.LabeledCount) []dtos.LabeledCount {
	items := mergeLabeledCounts(raw, normalizeLabel)

	sort.SliceStable(items, func(i, j int) bool {
		return items[i].Total > items[j].Total
	})

	if len(items) <= pekerjaanBreakdownTopN {
		return items
	}

	top := make([]dtos.LabeledCount, pekerjaanBreakdownTopN)
	copy(top, items[:pekerjaanBreakdownTopN])

	var othersTotal int64
	for _, it := range items[pekerjaanBreakdownTopN:] {
		othersTotal += it.Total
	}
	if othersTotal > 0 {
		top = append(top, dtos.LabeledCount{Label: "Lainnya", Total: othersTotal})
	}

	return top
}

// bucketForAge maps a single age in years to its ageGroupBuckets label.
func bucketForAge(age int) string {
	for _, b := range ageGroupBuckets {
		if b.MaxYears == -1 || age <= b.MaxYears {
			return b.Label
		}
	}
	return ageGroupBuckets[len(ageGroupBuckets)-1].Label
}

// buildUsiaBreakdown buckets raw per-resident ages (from GetAllAges) into
// ageGroupBuckets, youngest to oldest, omitting any bucket nobody falls
// into rather than showing a zero-width row.
func buildUsiaBreakdown(ages []int) []dtos.LabeledCount {
	counts := make(map[string]int64, len(ageGroupBuckets))
	for _, age := range ages {
		// A negative age means a birthdate in the future — bad legacy data,
		// not a real bucket to count.
		if age < 0 {
			continue
		}
		counts[bucketForAge(age)]++
	}

	var result []dtos.LabeledCount
	for _, b := range ageGroupBuckets {
		if total, ok := counts[b.Label]; ok {
			result = append(result, dtos.LabeledCount{Label: b.Label, Total: total})
		}
	}
	return result
}
