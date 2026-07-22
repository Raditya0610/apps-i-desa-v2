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

	wg.Add(2)
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

// mergeLabeledCounts normalizes labels and folds duplicates that collapse
// onto the same normalized label (e.g. "" and "-" both becoming "Tidak
// Diketahui") into a single summed entry, preserving first-seen order.
func mergeLabeledCounts(items []dtos.LabeledCount) []dtos.LabeledCount {
	totals := make(map[string]int64, len(items))
	var order []string
	for _, it := range items {
		label := normalizeLabel(it.Label)
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
	items := mergeLabeledCounts(raw)

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
	items := mergeLabeledCounts(raw)

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
