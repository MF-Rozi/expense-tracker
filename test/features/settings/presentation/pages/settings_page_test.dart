import 'package:expense_tracker/features/easter_egg/data/datasources/easter_egg_storage.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/helpers.dart';

class _RecordingFlashCubit extends FlashCubit {
  final List<String> messages = [];

  @override
  Future<void> displayFlash(String message) async {
    messages.add(message);
  }
}

void main() {
  late SharedPreferences preferences;
  late _RecordingFlashCubit flashCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    flashCubit = _RecordingFlashCubit();
  });

  Future<EasterEggCubit> buildCubit() async =>
      EasterEggCubit(EasterEggStorageImpl(preferences), flashCubit);

  testWidgets('shows the ritual dialog exactly once on the 7th version tap',
      (tester) async {
    final cubit = await buildCubit();
    await tester.pumpApp(SettingsPage(easterEggCubit: cubit));

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Version'));
      await tester.pump();
    }
    expect(find.text('You found something...'), findsNothing);

    await tester.tap(find.text('Version'));
    await tester.pump();
    expect(find.text('You found something...'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    // Further taps never re-show the dialog.
    await tester.tap(find.text('Version'));
    await tester.pump();
    expect(find.text('You found something...'), findsNothing);
  });

  testWidgets('version subtitle tracks ritual progress', (tester) async {
    final cubit = await buildCubit();
    await tester.pumpApp(SettingsPage(easterEggCubit: cubit));
    expect(find.text('1.0.0'), findsOneWidget);

    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Version'));
      await tester.pump();
    }
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.textContaining('(0/3 steps)'), findsOneWidget);
  });

  testWidgets('counter tile appears only when unlocked', (tester) async {
    final cubit = await buildCubit();
    await tester.pumpApp(SettingsPage(easterEggCubit: cubit));
    expect(find.text('Counter'), findsNothing);

    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('Version'));
      await tester.pump();
    }
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    cubit
      ..onTransactionLogged()
      ..onStatsVisited()
      ..onCategoriesOpened();
    await tester.pumpAndSettle();

    expect(find.text('Counter'), findsOneWidget);
    expect(find.text('Secret unlocked — Counter is below'), findsOneWidget);
  });
}
