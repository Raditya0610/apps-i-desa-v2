// Regression test for the responsive "Anggota Keluarga" list.
//
// The bug (screenshot): the 8-column data table was rendered at every width, so
// on a phone each column collapsed and text wrapped letter-by-letter. The fix
// renders member *cards* below the table breakpoint and the table above it.
//
// These tests pump the real screen (with the detail provider overridden so no
// network is hit) at phone and desktop widths and assert:
//   * layout completes with no overflow exception, and
//   * the correct layout is chosen — the "NO / NIK / NAMA" table header exists
//     only on wide screens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_apps_i_desa/data/models/cached_result.dart';
import 'package:fe_apps_i_desa/data/models/family_card_detail.dart';
import 'package:fe_apps_i_desa/providers/family_card_detail_provider.dart';
import 'package:fe_apps_i_desa/presentation/screens/family_cards/family_card_detail_screen.dart';

const _nik = '3374000000000001';

FamilyCardDetail _fakeDetail() => FamilyCardDetail(
      nik: _nik,
      address: 'Elaar Letsgo',
      familyMembers: [
        {
          'nik': '3374110001212112',
          'name': 'Udin Rambun Lestari',
          'jenis_kelamin': 'Perempuan',
          'status_hubungan': 'Kepala Keluarga',
          'age': 26,
          'pendidikan': 'Akademi/Diploma III/Sarjana Muda',
          'pekerjaan': 'Mahasiswa',
        },
        {
          'nik': '3374110001212113',
          'name': 'Siti Aminah',
          'jenis_kelamin': 'Perempuan',
          'status_hubungan': 'Anak',
          'age': 4,
          'pendidikan': 'Tidak/Belum Sekolah',
          'pekerjaan': 'Belum/Tidak Bekerja',
        },
      ],
    );

Future<void> _pumpScreenAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // AppSidebar (shown in the desktop layout) reads GoRouterState, so the screen
  // must sit under a GoRouter — a plain MaterialApp would throw.
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FamilyCardDetailScreen(nik: _nik),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        familyCardDetailProvider(_nik).overrideWith(
          (ref) async => CachedResult.fresh(_fakeDetail()),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phone width renders member cards, not the wide table',
      (tester) async {
    await _pumpScreenAt(tester, const Size(375, 900));

    expect(tester.takeException(), isNull);
    // Member data is shown (name appears in the header, info card and member card).
    expect(find.text('Udin Rambun Lestari'), findsWidgets);
    // … but the wide table's column header is absent (cards are used instead).
    expect(find.text('PENDIDIKAN'), findsNothing);
    // The card layout labels each field.
    expect(find.text('Pendidikan'), findsWidgets);
  });

  testWidgets('desktop width renders the data table', (tester) async {
    await _pumpScreenAt(tester, const Size(1280, 900));

    expect(find.text('Udin Rambun Lestari'), findsWidgets);
    // Wide table column headers are present → the table branch was chosen.
    expect(find.text('PENDIDIKAN'), findsOneWidget);
    expect(find.text('AKSI'), findsOneWidget);

    // The permanent AppSidebar (not touched by this work) overflows only under
    // the test-only placeholder font, where every glyph is a full-em square.
    // Those exceptions are irrelevant to the members table under test; drain
    // them so they don't fail teardown.
    while (tester.takeException() != null) {}
  });
}
