// Copyright (c) 2022, Adryan Eka Vandra & M. Fakhrul Rozi
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(() async {
    await configureInjector();
  });
  group('App', () {
    testWidgets('renders Splash Page', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(SplashPage), findsOneWidget);
    });
  });
}
