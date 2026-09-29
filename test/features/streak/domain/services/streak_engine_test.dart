import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/services/streak_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreakEngine engine;
  const defaultConfig = StreakConfig();

  setUp(() {
    engine = const StreakEngine();
  });

  group('StreakEngine', () {
    test('Empty record set -> empty streak, no crash', () {
      const today = StreakDay.fromYmd(2026, 9, 28);
      final result = engine.calculate(
        qualifyingPeriods: [],
        today: today,
        config: defaultConfig,
      );

      expect(result.current.isEmpty, isTrue);
      expect(result.current.length, 0);
      expect(result.current.status, StreakStatus.none);
      expect(result.current.daysUntilBreak, 0);
      expect(result.current.nextMilestone, 7);
      expect(result.current.consistencyRate, 0.0);
      expect(result.best.isEmpty, isTrue);
    });

    test(
        'Happy path: consecutive daily logs produce length equal to day span; '
        'minimum met -> active', () {
      // 5 consecutive days: Sept 20 to Sept 24, today is Sept 24 (qualified)
      final periods = [
        const StreakDay.fromYmd(2026, 9, 20),
        const StreakDay.fromYmd(2026, 9, 21),
        const StreakDay.fromYmd(2026, 9, 22),
        const StreakDay.fromYmd(2026, 9, 23),
        const StreakDay.fromYmd(2026, 9, 24),
      ];
      const today = StreakDay.fromYmd(2026, 9, 24);

      final result = engine.calculate(
        qualifyingPeriods: periods,
        today: today,
        config: defaultConfig,
      );

      expect(result.current.length, 5);
      expect(result.current.status, StreakStatus.active);
      expect(result.current.daysUntilBreak, 3);
      expect(result.current.nextMilestone, 7);
      expect(result.best.length, 5);
    });

    test(
        'Covers AE1: Window absorbs a 2-day gap at window 3; '
        'status at risk when today unqualified on last covered day', () {
      // Log on Sept 20, 21, 22 (length 3, minimum met).
      // Gap on Sept 23 (gap day 1) and Sept 24 (gap day 2) is absorbed.
      // Sept 25 is today: unqualified, delta = 25 - 22 = 3 == window 3.
      // Last covered day: window closes tomorrow (Sept 26 is delta 4 > 3).
      final periods = [
        const StreakDay.fromYmd(2026, 9, 20),
        const StreakDay.fromYmd(2026, 9, 21),
        const StreakDay.fromYmd(2026, 9, 22),
      ];
      const today = StreakDay.fromYmd(2026, 9, 25);

      final result = engine.calculate(
        qualifyingPeriods: periods,
        today: today,
        config: defaultConfig,
      );

      expect(result.current.length, 3);
      expect(result.current.status, StreakStatus.atRisk);
      expect(result.current.daysUntilBreak, 1);
      expect(result.best.length, 3);
    });

    test(
        'Covers AE2: Gap exceeding window ends the run; '
        'next qualifying day starts fresh run; best-run retains old run', () {
      // Saturday: Sept 20. Window: 3.
      // Sunday (Sept 21): 1 day passed.
      // Monday (Sept 22): 2 days passed.
      // Tuesday (Sept 23): 3 days passed.
      // Wednesday (Sept 24): 4 calendar days pass without log -> run ends!
      final saturdayLog = [
        const StreakDay.fromYmd(2026, 9, 18),
        const StreakDay.fromYmd(2026, 9, 19),
        const StreakDay.fromYmd(2026, 9, 20),
      ];
      const wednesday = StreakDay.fromYmd(2026, 9, 24);

      final resultWed = engine.calculate(
        qualifyingPeriods: saturdayLog,
        today: wednesday,
        config: defaultConfig,
      );

      expect(resultWed.current.length, 0);
      expect(resultWed.current.status, StreakStatus.broken);
      expect(resultWed.current.daysUntilBreak, 0);
      expect(resultWed.best.length, 3);

      // Thursday arrives and user logs: starts a fresh run!
      final withThursdayLog = [
        ...saturdayLog,
        const StreakDay.fromYmd(2026, 9, 25),
      ];
      const thursday = StreakDay.fromYmd(2026, 9, 25);

      final resultThu = engine.calculate(
        qualifyingPeriods: withThursdayLog,
        today: thursday,
        config: defaultConfig,
      );

      expect(resultThu.current.length, 1);
      expect(resultThu.current.status, StreakStatus.warmingUp);
      expect(resultThu.current.daysUntilBreak, 3);
      // Best run retains the older 3-day run!
      expect(resultThu.best.length, 3);
      expect(resultThu.current.bestLength, 3);
    });

    test(
        'Covers AE3: Length below minimum reports warming up, never active',
        () {
      // 2 consecutive days with minimum 3
      final periods = [
        const StreakDay.fromYmd(2026, 9, 20),
        const StreakDay.fromYmd(2026, 9, 21),
      ];
      const today = StreakDay.fromYmd(2026, 9, 21);

      final result = engine.calculate(
        qualifyingPeriods: periods,
        today: today,
        config: defaultConfig,
      );

      expect(result.current.length, 2);
      expect(result.current.status, StreakStatus.warmingUp);
      expect(result.current.status.isCelebratory, isFalse);
    });

    test(
        'Covers AE4: Backdating heals a run with a 2-day gap inside window',
        () {
      // User logs on Monday (Sept 21) and Friday (Sept 25).
      // Gap is 4 days > window 3, so they are separate runs.
      final disconnected = [
        const StreakDay.fromYmd(2026, 9, 21),
        const StreakDay.fromYmd(2026, 9, 25),
      ];
      const friday = StreakDay.fromYmd(2026, 9, 25);

      final resultBefore = engine.calculate(
        qualifyingPeriods: disconnected,
        today: friday,
        config: defaultConfig,
      );
      // Friday starts a fresh run of length 1
      expect(resultBefore.current.length, 1);

      // User backdates a transaction on Wednesday (Sept 23):
      // Sept 21 -> Sept 23 (gap 2 <= 3), Sept 23 -> Sept 25 (gap 2 <= 3)
      // Healed into single run spanning Sept 21 to Sept 25 inclusive = 5 days!
      final healed = [
        const StreakDay.fromYmd(2026, 9, 21),
        const StreakDay.fromYmd(2026, 9, 23),
        const StreakDay.fromYmd(2026, 9, 25),
      ];

      final resultAfter = engine.calculate(
        qualifyingPeriods: healed,
        today: friday,
        config: defaultConfig,
      );

      expect(resultAfter.current.length, 5);
      expect(resultAfter.current.status, StreakStatus.active);
    });

    test('Today qualified -> never at risk regardless of older gaps', () {
      // Log on Sept 20, gap Sept 21 & Sept 22, log on Sept 23 (today)
      final periods = [
        const StreakDay.fromYmd(2026, 9, 18),
        const StreakDay.fromYmd(2026, 9, 19),
        const StreakDay.fromYmd(2026, 9, 20),
        const StreakDay.fromYmd(2026, 9, 23),
      ];
      const today = StreakDay.fromYmd(2026, 9, 23);

      final result = engine.calculate(
        qualifyingPeriods: periods,
        today: today,
        config: defaultConfig,
      );

      expect(result.current.status, StreakStatus.active);
      expect(result.current.status.isAtRisk, isFalse);
      expect(result.current.daysUntilBreak, 3);
    });

    test(
        'Covers AE5: Cadence 1 collapse (strict daily streak): '
        'skipped day consumes window capacity', () {
      // Cadence 1 (window 1, minimum 3)
      const cadence1Config = StreakConfig(window: 1, cadence: 1);

      final logs = [
        const StreakDay.fromYmd(2026, 9, 20),
        const StreakDay.fromYmd(2026, 9, 21),
        const StreakDay.fromYmd(2026, 9, 22),
      ];

      // On Sept 22 (today, qualified): active
      final resultDay22 = engine.calculate(
        qualifyingPeriods: logs,
        today: const StreakDay.fromYmd(2026, 9, 22),
        config: cadence1Config,
      );
      expect(resultDay22.current.length, 3);
      expect(resultDay22.current.status, StreakStatus.active);

      // On Sept 23 (unqualified): delta = 1 == window 1 -> at risk!
      final resultDay23 = engine.calculate(
        qualifyingPeriods: logs,
        today: const StreakDay.fromYmd(2026, 9, 23),
        config: cadence1Config,
      );
      expect(resultDay23.current.length, 3);
      expect(resultDay23.current.status, StreakStatus.atRisk);
      expect(resultDay23.current.daysUntilBreak, 1);

      // On Sept 24 (still unqualified): delta = 2 > window 1 -> broken!
      final resultDay24 = engine.calculate(
        qualifyingPeriods: logs,
        today: const StreakDay.fromYmd(2026, 9, 24),
        config: cadence1Config,
      );
      expect(resultDay24.current.length, 0);
      expect(resultDay24.current.status, StreakStatus.broken);
      expect(resultDay24.best.length, 3);
    });

    test(
        'Covers AE6: Cadence 7 spacing '
        '(opens on 1st and 7th continue, open on 9th breaks)', () {
      // Window 7 (app-open cadence 7)
      const cadence7Config = StreakConfig(window: 7, minimum: 1);

      // Opens on Sept 1 and Sept 7: difference is 6 <= 7 -> continuous run
      final opens = [
        const StreakDay.fromYmd(2026, 9, 1),
        const StreakDay.fromYmd(2026, 9, 7),
      ];

      final resultSept7 = engine.calculate(
        qualifyingPeriods: opens,
        today: const StreakDay.fromYmd(2026, 9, 7),
        config: cadence7Config,
      );
      // Span Sept 1 to Sept 7 inclusive = 7 days
      expect(resultSept7.current.length, 7);
      expect(resultSept7.current.status, StreakStatus.active);

      // What if open on Sept 1, then no open until Sept 9?
      // Difference is 9 - 1 = 8 > 7 -> breaks it!
      final brokenOpens = [
        const StreakDay.fromYmd(2026, 9, 1),
        const StreakDay.fromYmd(2026, 9, 9),
      ];
      final resultSept9 = engine.calculate(
        qualifyingPeriods: brokenOpens,
        today: const StreakDay.fromYmd(2026, 9, 9),
        config: cadence7Config,
      );
      // Sept 9 starts a fresh run of length 1; old run on Sept 1 had length 1
      expect(resultSept9.current.length, 1);
      expect(resultSept9.best.length, 1);
    });

    test(
        'Month-period run: consecutive qualifying months, '
        'gap absorption across year boundary (Dec -> Jan)', () {
      const monthConfig = StreakConfig(window: 2, minimum: 2);
      final months = [
        const StreakMonth(2025, 11),
        const StreakMonth(2025, 12),
        const StreakMonth(2026, 1),
      ];
      const today = StreakMonth(2026, 1);

      final result = engine.calculate(
        qualifyingPeriods: months,
        today: today,
        config: monthConfig,
        type: StreakType.underBudget,
      );

      // 3 consecutive months: Nov 2025, Dec 2025, Jan 2026
      expect(result.current.length, 3);
      expect(result.current.status, StreakStatus.active);

      // Gap across year boundary absorbed: Nov 2025 to Jan 2026 with window 2
      final gapMonths = [
        const StreakMonth(2025, 11),
        const StreakMonth(2026, 1),
      ];
      final resultGap = engine.calculate(
        qualifyingPeriods: gapMonths,
        today: today,
        config: monthConfig,
        type: StreakType.underBudget,
      );
      // Difference = 2 <= 2, span is (2026-01 - 2025-11) + 1 = 3 months
      expect(resultGap.current.length, 3);
      expect(resultGap.current.status, StreakStatus.active);
    });

    test(
        'DST / timezone safety: dates passed through local-date stripping; '
        'no UTC arithmetic shifts the day bucket', () {
      // Days at the European daylight savings boundary (March 29, 2026)
      final periods = [
        StreakDay.fromDateTime(DateTime(2026, 3, 28, 23, 59)),
        StreakDay.fromDateTime(DateTime(2026, 3, 29, 0, 1)),
        StreakDay.fromDateTime(DateTime(2026, 3, 30, 12)),
      ];
      final today = StreakDay.fromDateTime(DateTime(2026, 3, 30, 18));

      final result = engine.calculate(
        qualifyingPeriods: periods,
        today: today,
        config: defaultConfig,
      );

      expect(result.current.length, 3);
      expect(result.current.status, StreakStatus.active);
    });

    test('Consistency rate: qualifying days in month divided by elapsed days',
        () {
      // Today is Sept 10 (10 days elapsed in container).
      // 5 qualifying days in Sept: 1, 2, 3, 4, 5
      final periods = [
        const StreakDay.fromYmd(2026, 9, 1),
        const StreakDay.fromYmd(2026, 9, 2),
        const StreakDay.fromYmd(2026, 9, 3),
        const StreakDay.fromYmd(2026, 9, 4),
        const StreakDay.fromYmd(2026, 9, 5),
        // One from previous month (August) should not count toward September
        const StreakDay.fromYmd(2026, 8, 31),
      ];
      const today = StreakDay.fromYmd(2026, 9, 10);

      final result = engine.calculate(
        qualifyingPeriods: periods,
        today: today,
        config: defaultConfig,
      );

      // 5 qualifying in Sept / 10 elapsed = 0.50
      expect(result.current.consistencyRate, 0.5);
    });

    test('resolveNextMilestone returns correct threshold across ladder', () {
      expect(StreakEngine.resolveNextMilestone(0), 7);
      expect(StreakEngine.resolveNextMilestone(6), 7);
      expect(StreakEngine.resolveNextMilestone(7), 14);
      expect(StreakEngine.resolveNextMilestone(10), 14);
      expect(StreakEngine.resolveNextMilestone(14), 21);
      expect(StreakEngine.resolveNextMilestone(21), 30);
      expect(StreakEngine.resolveNextMilestone(30), 60);
      expect(StreakEngine.resolveNextMilestone(60), 90);
      expect(StreakEngine.resolveNextMilestone(90), 180);
      expect(StreakEngine.resolveNextMilestone(180), 365);
      expect(StreakEngine.resolveNextMilestone(365), 730);
      expect(StreakEngine.resolveNextMilestone(400), 730);
    });

    test(
        'Filters out future periods after today and handles '
        'unsorted duplicates', () {
      const today = StreakDay.fromYmd(2026, 9, 20);
      final unorderedWithFuture = [
        const StreakDay.fromYmd(2026, 9, 20),
        const StreakDay.fromYmd(2026, 9, 18),
        const StreakDay.fromYmd(2026, 9, 19),
        const StreakDay.fromYmd(2026, 9, 19), // duplicate
        const StreakDay.fromYmd(2026, 9, 25), // future
      ];

      final result = engine.calculate(
        qualifyingPeriods: unorderedWithFuture,
        today: today,
        config: defaultConfig,
      );

      expect(result.current.length, 3);
      expect(result.current.status, StreakStatus.active);
    });
  });
}
