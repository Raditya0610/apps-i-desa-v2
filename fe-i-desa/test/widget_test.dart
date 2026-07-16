// Smoke test: the app boots without throwing on the first frame.
//
// (The previous contents were the default `flutter create` counter template,
// which tested a widget this app does not have and always failed.)

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_apps_i_desa/app.dart';

void main() {
  testWidgets('app boots without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    // The first frame (splash/login) built without an exception.
    expect(tester.takeException(), isNull);
  });
}
