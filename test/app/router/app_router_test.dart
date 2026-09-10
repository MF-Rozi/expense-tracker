import 'package:expense_tracker/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureInjector();
  });

  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpRouter(
    WidgetTester tester,
    String location, {
    required bool isCounterUnlocked,
  }) {
    return tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router('/counter', () => isCounterUnlocked),
      ),
    );
  }

  testWidgets('redirects locked users from /counter to settings',
      (tester) async {
    await pumpRouter(tester, '/counter', isCounterUnlocked: false);
    await tester.pumpAndSettle();

    // App bar title + bottom-nav label both render "Settings"; the page
    // itself is confirmed by its unique list tile.
    expect(find.text('Manage Categories'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
  });

  testWidgets('unlocked users reach the counter', (tester) async {
    await pumpRouter(tester, '/counter', isCounterUnlocked: true);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.text('Counter'), findsOneWidget);
  });
}
