class ApiConstants {
  // Base URL — override at build time:
  //   flutter run --dart-define=BASE_URL=http://localhost:3000
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://be-apps-i-desa.vercel.app',
  );
  static const String apiPrefix = '/api';

  // Auth Endpoints
  static const String login = '$apiPrefix/auth/login';
  static const String logout = '$apiPrefix/auth/logout';
  static const String register = '$apiPrefix/users/register';

  // Village Endpoints
  static const String villages = '$apiPrefix/villages';

  // Family Card Endpoints
  static const String familyCards = '$apiPrefix/family-cards';
  static String familyCardById(String nik) => '$familyCards/$nik';

  // Villager Endpoints
  static const String villagers = '$apiPrefix/villagers';
  static String villagerByNik(String nik) => '$villagers/$nik';

  // Dashboard
  static const String dashboard = '$apiPrefix/dashboard';

  // Sub-Dimension Endpoints
  static const String subDimensionPendidikan = '$apiPrefix/sub-dimensions/pendidikan';
  static const String subDimensionKesehatan = '$apiPrefix/sub-dimensions/kesehatan';
  static const String subDimensionUtilitasDasar = '$apiPrefix/sub-dimensions/utilitas-dasar';
  static const String subDimensionAktivitas = '$apiPrefix/sub-dimensions/aktivitas';
  static const String subDimensionFasilitasMasyarakat = '$apiPrefix/sub-dimensions/fasilitas-masyarakat';
  static const String subDimensionProduksiDesa = '$apiPrefix/sub-dimensions/produksi-desa';
  static const String subDimensionFasilitasPendukungEkonomi = '$apiPrefix/sub-dimensions/fasilitas-pendukung-ekonomi';
  static const String subDimensionPengelolaanLingkungan = '$apiPrefix/sub-dimensions/pengelolaan-lingkungan';
  static const String subDimensionPenanggulanganBencana = '$apiPrefix/sub-dimensions/penanggulangan-bencana';
  static const String subDimensionKondisiAksesJalan = '$apiPrefix/sub-dimensions/kondisi-akses-jalan';
  static const String subDimensionKemudahanAkses = '$apiPrefix/sub-dimensions/kemudahan-akses';
  static const String subDimensionKelembagaanPelayananDesa = '$apiPrefix/sub-dimensions/kelembagaan-pelayanan-desa';
  static const String subDimensionTataKelolaKeuanganDesa = '$apiPrefix/sub-dimensions/tata-kelola-keuangan-desa';

  // User
  static const String changePassword = '$apiPrefix/users/change-password';

  // Sub-dimension by ID helpers
  static String subDimensionPendidikanById(String id) => '$subDimensionPendidikan/$id';
  static String subDimensionKesehatanById(String id) => '$subDimensionKesehatan/$id';
  static String subDimensionUtilitasDasarById(String id) => '$subDimensionUtilitasDasar/$id';
  static String subDimensionAktivitasById(String id) => '$subDimensionAktivitas/$id';
  static String subDimensionFasilitasMasyarakatById(String id) => '$subDimensionFasilitasMasyarakat/$id';
  static String subDimensionProduksiDesaById(String id) => '$subDimensionProduksiDesa/$id';
  static String subDimensionFasilitasPendukungEkonomiById(String id) => '$subDimensionFasilitasPendukungEkonomi/$id';
  static String subDimensionPengelolaanLingkunganById(String id) => '$subDimensionPengelolaanLingkungan/$id';
  static String subDimensionPenanggulanganBencanaById(String id) => '$subDimensionPenanggulanganBencana/$id';
  static String subDimensionKondisiAksesJalanById(String id) => '$subDimensionKondisiAksesJalan/$id';
  static String subDimensionKemudahanAksesById(String id) => '$subDimensionKemudahanAkses/$id';
  static String subDimensionKelembagaanPelayananDesaById(String id) => '$subDimensionKelembagaanPelayananDesa/$id';
  static String subDimensionTataKelolaKeuanganDesaById(String id) => '$subDimensionTataKelolaKeuanganDesa/$id';

  // Cookie
  static const String cookieName = 'AppsIDesaCookie';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
