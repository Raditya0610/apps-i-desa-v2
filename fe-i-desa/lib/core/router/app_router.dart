import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/family_cards/family_cards_screen.dart';
import '../../presentation/screens/family_cards/family_card_detail_screen.dart';
import '../../presentation/screens/family_cards/add_family_card_screen.dart';
import '../../presentation/screens/sub_dimensions/sub_dimensions_hub_screen.dart';
import '../../presentation/screens/sub_dimensions/pendidikan_form_screen.dart';
import '../../presentation/screens/sub_dimensions/kesehatan_form_screen.dart';
import '../../presentation/screens/sub_dimensions/utilitas_dasar_form_screen.dart';
import '../../presentation/screens/sub_dimensions/aktivitas_form_screen.dart';
import '../../presentation/screens/sub_dimensions/fasilitas_masyarakat_form_screen.dart';
import '../../presentation/screens/sub_dimensions/produksi_desa_form_screen.dart';
import '../../presentation/screens/sub_dimensions/fasilitas_pendukung_ekonomi_form_screen.dart';
import '../../presentation/screens/sub_dimensions/pengelolaan_lingkungan_form_screen.dart';
import '../../presentation/screens/sub_dimensions/penanggulangan_bencana_form_screen.dart';
import '../../presentation/screens/sub_dimensions/kondisi_akses_jalan_form_screen.dart';
import '../../presentation/screens/sub_dimensions/kemudahan_akses_form_screen.dart';
import '../../presentation/screens/sub_dimensions/kelembagaan_pelayanan_desa_form_screen.dart';
import '../../presentation/screens/sub_dimensions/tata_kelola_keuangan_desa_form_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

// ChangeNotifier bridge so GoRouter can listen to Riverpod auth state.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    // refreshListenable keeps the same GoRouter instance alive and re-runs
    // redirect whenever auth state changes — fixes the "need to refresh" bug.
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      // Use ref.read (not watch) — GoRouter calls this in response to
      // refreshListenable notifications, not inside a widget build.
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/splash';

      if (isLoading && !isSplashRoute) return '/splash';
      if (!isLoading && isSplashRoute) return isAuthenticated ? '/' : '/login';
      if (!isLoading && !isAuthenticated && !isAuthRoute) return '/login';
      if (!isLoading && isAuthenticated && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _page(state, const SplashScreen(), auth: true),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _page(state, const LoginScreen(), auth: true),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _page(state, const RegisterScreen(), auth: true),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _page(state, const DashboardScreen()),
      ),
      GoRoute(
        path: '/family-cards',
        pageBuilder: (context, state) => _page(state, const FamilyCardsScreen()),
      ),
      GoRoute(
        path: '/family-cards/add',
        pageBuilder: (context, state) => _page(state, const AddFamilyCardScreen()),
      ),
      GoRoute(
        path: '/family-cards/:nik',
        pageBuilder: (context, state) {
          final nik = state.pathParameters['nik']!;
          return _page(state, FamilyCardDetailScreen(nik: nik));
        },
      ),
      GoRoute(
        path: '/sub-dimensions',
        pageBuilder: (context, state) => _page(state, const SubDimensionsHubScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/pendidikan',
        pageBuilder: (context, state) => _page(state, const PendidikanFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/kesehatan',
        pageBuilder: (context, state) => _page(state, const KesehatanFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/utilitas-dasar',
        pageBuilder: (context, state) => _page(state, const UtilitasDasarFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/aktivitas',
        pageBuilder: (context, state) => _page(state, const AktivitasFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/fasilitas-masyarakat',
        pageBuilder: (context, state) => _page(state, const FasilitasMasyarakatFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/produksi-desa',
        pageBuilder: (context, state) => _page(state, const ProduksiDesaFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/fasilitas-ekonomi',
        pageBuilder: (context, state) => _page(state, const FasilitasPendukungEkonomiFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/pengelolaan-lingkungan',
        pageBuilder: (context, state) => _page(state, const PengelolaanLingkunganFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/penanggulangan-bencana',
        pageBuilder: (context, state) => _page(state, const PenanggulanganBencanaFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/kondisi-akses-jalan',
        pageBuilder: (context, state) => _page(state, const KondisiAksesJalanFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/kemudahan-akses',
        pageBuilder: (context, state) => _page(state, const KemudahanAksesFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/kelembagaan-pelayanan',
        pageBuilder: (context, state) => _page(state, const KelembagaanPelayananDesaFormScreen()),
      ),
      GoRoute(
        path: '/sub-dimensions/tata-kelola-keuangan',
        pageBuilder: (context, state) => _page(state, const TataKelolaKeuanganDesaFormScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
});

CustomTransitionPage<void> _page(
  GoRouterState state,
  Widget child, {
  bool auth = false,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: auth ? _fadeTransition : _fadeSlideTransition,
  );
}

Widget _fadeSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}
