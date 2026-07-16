// Regression test for the responsive member form dialog.
//
// The bug: on phone-width screens the two-column Rows (e.g. Pendidikan +
// Pekerjaan) became too narrow and the dropdown's long text overflowed onto
// the neighbouring field. Flutter reports layout overflow by drawing the
// yellow/black stripes AND, in tests, by recording an exception during layout.
// Pumping the dialog at 375px must therefore complete with zero exceptions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fe_apps_i_desa/presentation/widgets/family_cards/villager_form_dialog.dart';

Future<void> _pumpDialogAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VillagerFormDialog(
          familyCardId: '1234567890123456',
          onSuccess: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('member form dialog lays out without overflow on a 375px phone',
      (tester) async {
    await _pumpDialogAt(tester, const Size(375, 800));

    // No RenderFlex overflow (or any other) exception was thrown during layout.
    expect(tester.takeException(), isNull);

    // Core fields are present.
    expect(find.text('Tambah Anggota Keluarga'), findsOneWidget);
    expect(find.text('Pendidikan *'), findsOneWidget);
    expect(find.text('Pekerjaan *'), findsOneWidget);
    expect(find.text('Data Pribadi'), findsOneWidget);
  });

  testWidgets('member form dialog also lays out cleanly on a wide screen',
      (tester) async {
    await _pumpDialogAt(tester, const Size(1200, 900));
    expect(tester.takeException(), isNull);
    expect(find.text('Tambah Anggota Keluarga'), findsOneWidget);
  });
}
