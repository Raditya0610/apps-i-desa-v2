class FamilyCardDetail {
  final String nik;
  final String address;
  final String rt;
  final String rw;
  final String kelurahan;
  final String kecamatan;
  final String kabupatenKota;
  final String kodePos;
  final String provinsi;
  final List<Map<String, dynamic>> familyMembers;

  FamilyCardDetail({
    required this.nik,
    required this.address,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    required this.kecamatan,
    required this.kabupatenKota,
    required this.kodePos,
    required this.provinsi,
    required this.familyMembers,
  });

  int get totalMembers => familyMembers.length;

  String get name {
    // Get the name of the head of family (Kepala Keluarga)
    final head = familyMembers.firstWhere(
      (member) =>
          member['status_hubungan'] == 'Kepala Keluarga',
      orElse: () => {},
    );
    return head['name'] as String? ?? 'Tidak ada kepala keluarga';
  }

  factory FamilyCardDetail.fromJson(Map<String, dynamic> json) {
    return FamilyCardDetail(
      nik: json['nik'] as String,
      address: json['address'] as String? ?? '',
      rt: json['rt'] as String? ?? '',
      rw: json['rw'] as String? ?? '',
      kelurahan: json['kelurahan'] as String? ?? '',
      kecamatan: json['kecamatan'] as String? ?? '',
      kabupatenKota: json['kabupaten_kota'] as String? ?? '',
      kodePos: json['kode_pos'] as String? ?? '',
      provinsi: json['provinsi'] as String? ?? '',
      familyMembers: (json['family_members'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
