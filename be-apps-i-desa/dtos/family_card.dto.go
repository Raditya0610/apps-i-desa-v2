package dtos

// FamilyCardsResponse represents the response structure for family cards.
type GetAllFamilyCardsResponse struct {
	FamilyCards []GetFamilyCardResponse `json:"family_cards"`
}

// FamilyCardResponse represents the structure of a single family card response.
type GetFamilyCardResponse struct {
	NIK          string  `json:"nik"`
	Name         *string `json:"name,omitempty"`
	TotalMembers int     `json:"total_members"`
}

// GetAllFamilyMember is the response for GET /api/family-cards/:id. RT/RW/
// Kelurahan/Kecamatan/KabupatenKota/KodePos/Provinsi are included so the
// frontend's edit form can prefill current values instead of asking staff to
// retype every field just to correct one of them.
type GetAllFamilyMember struct {
	NIK           string            `json:"nik"`
	Address       string            `json:"address"`
	RT            string            `json:"rt"`
	RW            string            `json:"rw"`
	Kelurahan     string            `json:"kelurahan"`
	Kecamatan     string            `json:"kecamatan"`
	KabupatenKota string            `json:"kabupaten_kota"`
	KodePos       string            `json:"kode_pos"`
	Provinsi      string            `json:"provinsi"`
	FamilyMembers []GetFamilyMember `json:"family_members"`
}

type AddFamilyCardRequest struct {
	NIK           string `json:"nik"            validate:"required,len=16,numeric"`
	Address       string `json:"address"        validate:"required"`
	RT            string `json:"rt"             validate:"required"`
	RW            string `json:"rw"             validate:"required"`
	Kelurahan     string `json:"kelurahan"      validate:"required"`
	Kecamatan     string `json:"kecamatan"      validate:"required"`
	KabupatenKota string `json:"kabupaten_kota" validate:"required"`
	KodePos       string `json:"kode_pos"       validate:"required"`
	Provinsi      string `json:"provinsi"       validate:"required"`
}

// UpdateFamilyCardRequest is a partial update — every field is optional so a
// caller only needs to send what actually changed. NIK is deliberately not
// included: it's the record's own primary key, not an editable attribute.
type UpdateFamilyCardRequest struct {
	Address       *string `json:"address,omitempty"        validate:"omitempty"`
	RT            *string `json:"rt,omitempty"             validate:"omitempty"`
	RW            *string `json:"rw,omitempty"             validate:"omitempty"`
	Kelurahan     *string `json:"kelurahan,omitempty"      validate:"omitempty"`
	Kecamatan     *string `json:"kecamatan,omitempty"      validate:"omitempty"`
	KabupatenKota *string `json:"kabupaten_kota,omitempty" validate:"omitempty"`
	KodePos       *string `json:"kode_pos,omitempty"       validate:"omitempty"`
	Provinsi      *string `json:"provinsi,omitempty"       validate:"omitempty"`
}
