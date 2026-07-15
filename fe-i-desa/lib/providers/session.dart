import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'activity_log_provider.dart';
import 'aktivitas_provider.dart';
import 'dashboard_provider.dart';
import 'family_card_detail_provider.dart';
import 'family_card_provider.dart';
import 'fasilitas_masyarakat_provider.dart';
import 'fasilitas_pendukung_ekonomi_provider.dart';
import 'idm_score_provider.dart';
import 'kelembagaan_pelayanan_desa_provider.dart';
import 'kemudahan_akses_provider.dart';
import 'kesehatan_provider.dart';
import 'kondisi_akses_jalan_provider.dart';
import 'penanggulangan_bencana_provider.dart';
import 'pendidikan_provider.dart';
import 'pengelolaan_lingkungan_provider.dart';
import 'produksi_desa_provider.dart';
import 'tata_kelola_keuangan_desa_provider.dart';
import 'utilitas_dasar_provider.dart';
import 'villager_provider.dart';

/// Drops every provider that holds data belonging to the logged-in village.
///
/// These are StateNotifier/FutureProviders that fetch once in their constructor
/// and then stay alive for the whole app session. Without this, logging in as a
/// different user showed the previous user's data — the providers already existed
/// and never re-fetched. That is a cross-village PII leak, not just stale UI.
///
/// Call this whenever the authenticated identity changes (login, logout, account
/// switch). Invalidating disposes each provider so the next read rebuilds it and
/// re-fetches under the new session's token.
///
/// Deliberately excluded: villagesProvider (the public village list for the
/// registration dropdown, not tied to a session) and repository/service
/// providers (stateless).
void invalidateSessionData(WidgetRef ref) {
  ref.invalidate(dashboardProvider);
  ref.invalidate(familyCardsProvider);
  ref.invalidate(familyCardDetailProvider); // family: clears every cached nik
  ref.invalidate(villagersProvider);
  ref.invalidate(recentActivitiesProvider);
  ref.invalidate(idmScoreProvider);

  // Sub-dimension (IDM indicator) forms
  ref.invalidate(pendidikanProvider);
  ref.invalidate(kesehatanProvider);
  ref.invalidate(utilitasDasarProvider);
  ref.invalidate(aktivitasProvider);
  ref.invalidate(fasilitasMasyarakatProvider);
  ref.invalidate(produksiDesaProvider);
  ref.invalidate(fasilitasPendukungEkonomiProvider);
  ref.invalidate(pengelolaanLingkunganProvider);
  ref.invalidate(penanggulanganBencanaProvider);
  ref.invalidate(kondisiAksesJalanProvider);
  ref.invalidate(kemudahanAksesProvider);
  ref.invalidate(kelembagaanPelayananDesaProvider);
  ref.invalidate(tataKelolaKeuanganDesaProvider);
}
