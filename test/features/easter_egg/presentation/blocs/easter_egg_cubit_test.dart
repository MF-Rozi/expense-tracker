import 'package:expense_tracker/features/easter_egg/data/datasources/easter_egg_storage.dart';
import 'package:expense_tracker/features/easter_egg/domain/entities/easter_egg_progress.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  EasterEggCubit buildCubit() =>
      EasterEggCubit(EasterEggStorageImpl(preferences), flashCubit);
  void revealHint(EasterEggCubit cubit) {
    for (var i = 0; i < EasterEggProgress.versionTapsRequired; i++) {
      cubit.onVersionTapped();
    }
  }

  group('EasterEggCubit', () {
    test('starts locked with zero progress', () {
      final cubit = buildCubit();
      expect(cubit.state.progress.unlocked, isFalse);
      expect(cubit.state.progress.versionTaps, 0);
      expect(cubit.state.progress.hintSeen, isFalse);
    });

    test('reveals hint exactly on the 7th version tap', () {
      final cubit = buildCubit()
        ..onVersionTapped()
        ..onVersionTapped();
      expect(cubit.state.progress.hintSeen, isFalse);

      for (var i = 2; i < EasterEggProgress.versionTapsRequired - 1; i++) {
        cubit.onVersionTapped();
      }
      expect(cubit.state.progress.hintSeen, isFalse);

      cubit.onVersionTapped();
      expect(cubit.state.progress.hintSeen, isTrue);
      expect(cubit.state.justRevealedHint, isTrue);
      expect(cubit.state.progress.unlocked, isFalse);

      // The edge-triggered flag clears on the next state change so the
      // ritual dialog neither stacks nor re-shows.
      cubit.onVersionTapped();
      expect(cubit.state.justRevealedHint, isFalse);
    });

    test('does not count steps before the hint is seen', () {
      final cubit = buildCubit()
        ..onTransactionLogged()
        ..onStatsVisited()
        ..onCategoriesOpened();

      expect(cubit.state.progress.completedSteps, 0);
      expect(cubit.state.progress.unlocked, isFalse);
    });

    test('unlocks after all three steps once the hint is seen', () {
      final cubit = buildCubit();
      revealHint(cubit);

      cubit.onTransactionLogged();
      expect(cubit.state.progress.completedSteps, 1);
      expect(cubit.state.progress.unlocked, isFalse);

      cubit
        ..onStatsVisited()
        ..onCategoriesOpened();

      expect(cubit.state.progress.unlocked, isTrue);
      expect(flashCubit.messages, hasLength(1));
      expect(flashCubit.messages.first, contains('Counter'));
    });

    test('steps are idempotent', () {
      final cubit = buildCubit();
      revealHint(cubit);

      cubit
        ..onTransactionLogged()
        ..onTransactionLogged()
        ..onTransactionLogged();

      expect(cubit.state.progress.completedSteps, 1);
      expect(cubit.state.progress.unlocked, isFalse);
    });

    test('progress persists across instances', () {
      final cubit = buildCubit();
      revealHint(cubit);
      cubit
        ..onTransactionLogged()
        ..onStatsVisited()
        ..onCategoriesOpened();
      expect(cubit.state.progress.unlocked, isTrue);

      final restored = buildCubit();
      expect(restored.state.progress.unlocked, isTrue);
      expect(restored.state.progress.completedSteps, 3);
      // The dialog must not re-show after a restart.
      expect(restored.state.justRevealedHint, isFalse);
    });

    test('mid-ritual state restores and completes', () {
      final first = buildCubit();
      revealHint(first);
      first
        ..onTransactionLogged()
        ..onStatsVisited();
      expect(first.state.progress.unlocked, isFalse);

      final restored = buildCubit();
      expect(restored.state.justRevealedHint, isFalse);
      expect(restored.state.progress.hintSeen, isTrue);
      expect(restored.state.progress.completedSteps, 2);
      expect(restored.state.progress.unlocked, isFalse);

      restored.onCategoriesOpened();
      expect(restored.state.progress.unlocked, isTrue);
      expect(flashCubit.messages, hasLength(1));
    });

    test('self-heals a partial unlock write on restore', () async {
      // Simulates the app dying mid-write of the unlocking transition:
      // all three steps persisted, but the unlocked flag was lost.
      const stuck = EasterEggProgress(
        hintSeen: true,
        loggedTransaction: true,
        visitedStats: true,
        openedCategories: true,
      );
      await EasterEggStorageImpl(preferences).write(stuck);

      final restored = buildCubit();
      expect(restored.state.progress.unlocked, isTrue);
      expect(restored.state.progress.completedSteps, 3);
    });

    test('version taps stop counting once unlocked', () {
      final cubit = buildCubit();
      revealHint(cubit);
      cubit
        ..onTransactionLogged()
        ..onStatsVisited()
        ..onCategoriesOpened();
      expect(cubit.state.progress.unlocked, isTrue);

      cubit.onVersionTapped();
      expect(
        cubit.state.progress.versionTaps,
        EasterEggProgress.versionTapsRequired,
      );
    });

    test('deactivate resets the whole ritual', () {
      final cubit = buildCubit();
      revealHint(cubit);
      cubit
        ..onTransactionLogged()
        ..onStatsVisited()
        ..onCategoriesOpened();
      expect(cubit.state.progress.unlocked, isTrue);

      cubit.deactivate();
      expect(cubit.state.progress, const EasterEggProgress());
      expect(flashCubit.messages.last, contains('locked again'));

      // Steps no longer count and the hint must be revealed again with
      // seven fresh taps — like re-enabling Android's developer options.
      cubit.onTransactionLogged();
      expect(cubit.state.progress.completedSteps, 0);
      revealHint(cubit);
      cubit.onTransactionLogged();
      expect(cubit.state.progress.completedSteps, 1);
    });

    test('deactivate does nothing before unlocking', () {
      final cubit = buildCubit()..deactivate();

      expect(cubit.state.progress.versionTaps, 0);
      expect(flashCubit.messages, isEmpty);
    });

    test('deactivated state persists across instances', () {
      final cubit = buildCubit();
      revealHint(cubit);
      cubit
        ..onTransactionLogged()
        ..onStatsVisited()
        ..onCategoriesOpened()
        ..deactivate();

      final restored = buildCubit();
      expect(restored.state.progress.unlocked, isFalse);
      expect(restored.state.progress.versionTaps, 0);
      expect(restored.state.justRevealedHint, isFalse);
    });
  });
}
