package services

import (
	"testing"

	"Apps-I_Desa_Backend/dtos"
)

func TestBuildPendidikanBreakdownOrdersByLevelNotCount(t *testing.T) {
	raw := []dtos.LabeledCount{
		{Label: "Strata II", Total: 50}, // highest count, should NOT sort first
		{Label: "Tidak/Belum Sekolah", Total: 1},
		{Label: "SLTA/Sederajat", Total: 10},
		{Label: "", Total: 2},  // blank -> "Tidak Diketahui"
		{Label: "-", Total: 3}, // dash placeholder -> merges into "Tidak Diketahui" too
	}

	got := buildPendidikanBreakdown(raw)

	wantOrder := []string{"Tidak/Belum Sekolah", "SLTA/Sederajat", "Strata II", "Tidak Diketahui"}
	if len(got) != len(wantOrder) {
		t.Fatalf("got %d items, want %d: %+v", len(got), len(wantOrder), got)
	}
	for i, label := range wantOrder {
		if got[i].Label != label {
			t.Errorf("index %d: got label %q, want %q", i, got[i].Label, label)
		}
	}

	// "" (2) + "-" (3) must merge into one "Tidak Diketahui" bucket of 5.
	last := got[len(got)-1]
	if last.Label != "Tidak Diketahui" || last.Total != 5 {
		t.Errorf("expected merged Tidak Diketahui total=5, got %+v", last)
	}
}

func TestBuildPekerjaanBreakdownCapsAndSortsByCount(t *testing.T) {
	raw := make([]dtos.LabeledCount, 0, 10)
	for i := 0; i < 10; i++ {
		raw = append(raw, dtos.LabeledCount{Label: string(rune('A' + i)), Total: int64(i + 1)})
	}
	// "J" has the highest count (10) and should end up first.

	got := buildPekerjaanBreakdown(raw)

	if len(got) != pekerjaanBreakdownTopN+1 { // +1 for the "Lainnya" bucket
		t.Fatalf("got %d items, want %d (top %d + Lainnya): %+v", len(got), pekerjaanBreakdownTopN+1, pekerjaanBreakdownTopN, got)
	}
	if got[0].Label != "J" || got[0].Total != 10 {
		t.Errorf("expected top item to be J/10, got %+v", got[0])
	}

	last := got[len(got)-1]
	if last.Label != "Lainnya" {
		t.Fatalf("expected last bucket to be Lainnya, got %+v", last)
	}
	// Remaining items after top 8 are counts 1+2 (A=1, B=2) = 3.
	if last.Total != 3 {
		t.Errorf("expected Lainnya total=3, got %d", last.Total)
	}
}

func TestBuildPekerjaanBreakdownNoOthersBucketWhenUnderCap(t *testing.T) {
	raw := []dtos.LabeledCount{
		{Label: "Petani", Total: 5},
		{Label: "Nelayan", Total: 3},
	}
	got := buildPekerjaanBreakdown(raw)
	if len(got) != 2 {
		t.Fatalf("expected no Lainnya bucket when under cap, got %+v", got)
	}
	if got[0].Label != "Petani" || got[1].Label != "Nelayan" {
		t.Errorf("expected sorted by count desc, got %+v", got)
	}
}
