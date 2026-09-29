import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakConfig', () {
    test('default values match requirements (3, 3, 7)', () {
      const config = StreakConfig();
      expect(config.window, 3);
      expect(config.minimum, 3);
      expect(config.cadence, 7);
    });

    test('asserts values must be at least 1', () {
      expect(
        () => StreakConfig(window: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => StreakConfig(minimum: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => StreakConfig(cadence: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('copyWith updates fields correctly', () {
      const config = StreakConfig();
      final updated = config.copyWith(window: 5, minimum: 4, cadence: 14);

      expect(updated.window, 5);
      expect(updated.minimum, 4);
      expect(updated.cadence, 14);
    });
  });

  group('StreakStatus', () {
    test('isCelebratory is true only for active and atRisk', () {
      expect(StreakStatus.none.isCelebratory, isFalse);
      expect(StreakStatus.warmingUp.isCelebratory, isFalse);
      expect(StreakStatus.broken.isCelebratory, isFalse);
      expect(StreakStatus.active.isCelebratory, isTrue);
      expect(StreakStatus.atRisk.isCelebratory, isTrue);
    });

    test('getters correctly reflect enum state', () {
      expect(StreakStatus.none.isNone, isTrue);
      expect(StreakStatus.warmingUp.isWarmingUp, isTrue);
      expect(StreakStatus.active.isActive, isTrue);
      expect(StreakStatus.atRisk.isAtRisk, isTrue);
      expect(StreakStatus.broken.isBroken, isTrue);
    });
  });

  group('StreakType', () {
    test('displayName returns user-friendly label', () {
      expect(StreakType.tracking.displayName, 'Tracking Streak');
      expect(StreakType.noSpend.displayName, 'No-Spend Streak');
      expect(StreakType.appOpen.displayName, 'App-Open Streak');
      expect(StreakType.underBudget.displayName, 'Under-Budget Streak');
    });
  });

  group('Streak', () {
    test('empty factory creates default empty streak', () {
      const empty = Streak.empty();
      expect(empty.length, 0);
      expect(empty.status, StreakStatus.none);
      expect(empty.daysUntilBreak, 0);
      expect(empty.nextMilestone, 7);
      expect(empty.consistencyRate, 0.0);
      expect(empty.bestLength, 0);
      expect(empty.isEmpty, isTrue);
    });

    test('copyWith creates updated instance', () {
      const initial = Streak.empty();
      final updated = initial.copyWith(
        length: 5,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 14,
        consistencyRate: 0.8,
        bestLength: 10,
      );

      expect(updated.length, 5);
      expect(updated.status, StreakStatus.active);
      expect(updated.daysUntilBreak, 2);
      expect(updated.nextMilestone, 14);
      expect(updated.consistencyRate, 0.8);
      expect(updated.bestLength, 10);
      expect(updated.isEmpty, isFalse);
    });
  });
}
