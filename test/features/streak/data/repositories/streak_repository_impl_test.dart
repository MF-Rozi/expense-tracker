import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/app_open_repository.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements TransactionRepository {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAppOpenRepository extends Mock implements AppOpenRepository {}

void main() {
  late MockTransactionRepository mockTxRepo;
  late MockLocalStorage mockStorage;
  late MockAppOpenRepository mockAppOpenRepo;
  late StreakRepositoryImpl repository;

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    mockStorage = MockLocalStorage();
    mockAppOpenRepo = MockAppOpenRepository();
    repository = StreakRepositoryImpl(
      mockTxRepo,
      mockStorage,
      mockAppOpenRepo,
    );

    // Default storage mocks
    when(() => mockStorage.getStreakWindowDays()).thenAnswer((_) async => 3);
    when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 3);
    when(() => mockStorage.getAppOpenCadenceDays()).thenAnswer((_) async => 7);
  });

  Transaction createTx(
    DateTime date, {
    TransactionType type = TransactionType.expense,
  }) {
    return Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(100),
      description: StringSingleLine('Test transaction'),
      date: date,
      categoryUuid: UniqueId.generate(),
      type: type,
    );
  }

  group('StreakRepositoryImpl.getStreak - Tracking', () {
    test(
        'Transactions on scattered days within window -> '
        'single run, calendar-span length', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10)),
        createTx(DateTime(2026, 9, 22, 15)),
        createTx(DateTime(2026, 9, 25, 9)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 6);
          expect(streak.status, StreakStatus.active);
          expect(streak.daysUntilBreak, 3);
          expect(streak.bestLength, 6);
        },
      );
    });

    test(
        'Two clusters separated by more than window -> '
        'current run is the recent one; best run is the longer cluster',
        () async {
      final refDate = DateTime(2026, 9, 22, 10);
      final transactions = [
        createTx(DateTime(2026, 9, 1, 8)),
        createTx(DateTime(2026, 9, 4, 12)),
        createTx(DateTime(2026, 9, 7, 18)),
        createTx(DateTime(2026, 9, 20, 11)),
        createTx(DateTime(2026, 9, 21, 14)),
        createTx(DateTime(2026, 9, 22, 9)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.active);
          expect(streak.bestLength, 7);
        },
      );
    });

    test('Gap strictly greater than window -> broken status and length 0',
        () async {
      final refDate = DateTime(2026, 9, 25, 18);
      final transactions = [
        createTx(DateTime(2026, 9, 20, 9)),
        createTx(DateTime(2026, 9, 21, 14)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.broken);
          expect(streak.daysUntilBreak, 0);
          expect(streak.bestLength, 2);
        },
      );
    });

    test('1 transaction recorded today -> length 1, warmingUp, not active',
        () async {
      final refDate = DateTime(2026, 9, 25, 10);
      final transactions = [
        createTx(DateTime(2026, 9, 25, 8)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 1);
          expect(streak.status, StreakStatus.warmingUp);
          expect(streak.status.isCelebratory, isFalse);
          expect(streak.daysUntilBreak, 3);
          expect(streak.bestLength, 1);
        },
      );
    });

    test('No transactions at all -> empty streak entity', () async {
      final refDate = DateTime(2026, 9, 25, 10);

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.isEmpty, isTrue);
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.none);
          expect(streak.daysUntilBreak, 0);
          expect(streak.consistencyRate, 0.0);
          expect(streak.bestLength, 0);
        },
      );
    });

    test('Propagates transaction repository failure as Left', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          Failure.localFailure(message: 'Database query failed'),
        ),
      );

      final result = await repository.getStreak();

      expect(result.isLeft(), isTrue);
    });
  });

  group('StreakRepositoryImpl.getStreak - No-Spend', () {
    test(
        'Expense-free days build a run; any expense that day '
        'disqualifies only that day', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      // History:
      // Sept 20: Income
      // Sept 21: Income
      // Sept 22: Expense -> disqualified
      // Sept 23: Income
      // Sept 24: Income
      // Sept 25: Income
      // Qualifying days: Sept 20, 21, 23, 24, 25.
      // Gap Sept 21 -> 23 is 2 days <= window 3.
      // Span Sept 20 to Sept 25 = 6 days.
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 21, 11), type: TransactionType.income),
        createTx(DateTime(2026, 9, 22, 12)),
        createTx(DateTime(2026, 9, 23, 14), type: TransactionType.income),
        createTx(DateTime(2026, 9, 24, 15), type: TransactionType.income),
        createTx(DateTime(2026, 9, 25, 9), type: TransactionType.income),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.type, StreakType.noSpend);
          expect(streak.length, 6);
          expect(streak.status, StreakStatus.active);
          expect(streak.bestLength, 6);
        },
      );
    });

    test('Income-only day still qualifies for no-spend streak', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      // Only income recorded on Sept 23, 24, 25
      final transactions = [
        createTx(DateTime(2026, 9, 23, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 24, 11), type: TransactionType.income),
        createTx(DateTime(2026, 9, 25, 9), type: TransactionType.income),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.type, StreakType.noSpend);
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.active);
        },
      );
    });

    test('Days with zero transactions between start and today qualify',
        () async {
      final refDate = DateTime(2026, 9, 23, 12);
      // User logged an income on Sept 21. No transactions on Sept 22 or 23.
      // Candidate days: Sept 21, Sept 22, Sept 23 -> all expense-free!
      final transactions = [
        createTx(DateTime(2026, 9, 21, 10), type: TransactionType.income),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.active);
        },
      );
    });

    test('Expense today with prior run -> remains active with window grace',
        () async {
      final refDate = DateTime(2026, 9, 23, 12);
      // Income on Sept 20, 21, 22. Expense on Sept 23 (today).
      // Last qualifying day is Sept 22. Delta = 1 <= window 3 ->
      // active with 3 days until break.
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 21, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 22, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 23, 10)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.active);
          expect(streak.daysUntilBreak, 3);
        },
      );
    });

    test(
        'Expense on last day of window coverage -> '
        'at risk with 1 day until break', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      // Income on Sept 20, 21, 22. Expenses on Sept 23, 24, 25.
      // Last qualifying day is Sept 22. Delta = 3 == window 3 -> atRisk!
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 21, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 22, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 23, 10)),
        createTx(DateTime(2026, 9, 24, 10)),
        createTx(DateTime(2026, 9, 25, 10)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.atRisk);
          expect(streak.daysUntilBreak, 1);
        },
      );
    });

    test('Empty transactions -> empty noSpend streak', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await repository.getStreak(type: StreakType.noSpend);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.isEmpty, isTrue);
          expect(streak.length, 0);
        },
      );
    });
  });

  group('StreakRepositoryImpl.getStreak - App-Open Consistency', () {
    test(
        'Covers AE5: Cadence 1 consecutive-day opens sustain run; '
        'skipped day consumes capacity -> at risk then broken', () async {
      when(() => mockStorage.getAppOpenCadenceDays())
          .thenAnswer((_) async => 1);
      final openDates = [
        DateTime(2026, 9, 20, 9),
        DateTime(2026, 9, 21, 10),
        DateTime(2026, 9, 22, 8),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(openDates));

      // Sept 22 (today, qualified): active
      final resultDay22 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 22, 12),
      );
      resultDay22.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.active);
          expect(streak.daysUntilBreak, 1);
        },
      );

      // Sept 23 (unqualified, gap = 1 == cadence 1): atRisk
      final resultDay23 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 23, 12),
      );
      resultDay23.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.atRisk);
          expect(streak.daysUntilBreak, 1);
        },
      );

      // Sept 24 (unqualified, gap = 2 > cadence 1): broken
      final resultDay24 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 24, 12),
      );
      resultDay24.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.broken);
          expect(streak.bestLength, 3);
        },
      );
    });

    test(
        'Covers AE6: Cadence 7 opens on 1st and 7th continue; '
        '9th breaks', () async {
      when(() => mockStorage.getAppOpenCadenceDays())
          .thenAnswer((_) async => 7);
      when(() => mockStorage.getStreakMinimumDays())
          .thenAnswer((_) async => 1);

      // Opens on Sept 1 and Sept 7: diff 6 <= 7 -> continues
      final opensCont = [
        DateTime(2026, 9, 1, 9),
        DateTime(2026, 9, 7, 10),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(opensCont));

      final resultSept7 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 7, 12),
      );
      resultSept7.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 7);
          expect(streak.status, StreakStatus.active);
        },
      );

      // Open on Sept 1 and Sept 9: diff 8 > 7 -> breaks, fresh run of length 1
      final opensBroken = [
        DateTime(2026, 9, 1, 9),
        DateTime(2026, 9, 9, 10),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(opensBroken));

      final resultSept9 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 9, 12),
      );
      resultSept9.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 1);
          expect(streak.bestLength, 1);
        },
      );
    });

    test('Custom cadence value (e.g. 5) drives the window', () async {
      when(() => mockStorage.getAppOpenCadenceDays())
          .thenAnswer((_) async => 5);
      when(() => mockStorage.getStreakMinimumDays())
          .thenAnswer((_) async => 1);

      // Opens on Sept 1 and Sept 6 (diff 5 <= 5): continuous run
      final opens = [
        DateTime(2026, 9, 1, 9),
        DateTime(2026, 9, 6, 10),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(opens));

      final result = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 6, 12),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 6);
          expect(streak.status, StreakStatus.active);
        },
      );
    });

    test('Propagates AppOpenRepository failure as Left', () async {
      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          Failure.localFailure(message: 'Storage read failure'),
        ),
      );

      final result = await repository.getStreak(type: StreakType.appOpen);

      expect(result.isLeft(), isTrue);
    });
  });

  group('StreakRepositoryImpl - UnderBudget & Unsupported', () {
    test('Returns Left for underBudget streak in phase 2', () async {
      final result = await repository.getStreak(type: StreakType.underBudget);
      expect(result.isLeft(), isTrue);

      final periodsResult = await repository.getQualifyingPeriods(
        type: StreakType.underBudget,
      );
      expect(periodsResult.isLeft(), isTrue);
    });
  });

  group('StreakRepositoryImpl.getQualifyingPeriods', () {
    test('extracts, deduplicates, and sorts qualifying dates for tracking',
        () async {
      final startDate = DateTime(2026, 9);
      final endDate = DateTime(2026, 9, 30);
      final transactions = [
        createTx(DateTime(2026, 9, 5, 10)),
        createTx(DateTime(2026, 9, 2, 8)),
        createTx(DateTime(2026, 9, 5, 16)), // duplicate day
        createTx(DateTime(2026, 9, 10, 12)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: startDate,
          endDate: endDate,
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getQualifyingPeriods(
        startDate: startDate,
        endDate: endDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakDay.fromYmd(2026, 9, 2),
            const StreakDay.fromYmd(2026, 9, 5),
            const StreakDay.fromYmd(2026, 9, 10),
          ]);
        },
      );
    });

    test('extracts qualifying dates for noSpend (expense-free days)', () async {
      final startDate = DateTime(2026, 9);
      final endDate = DateTime(2026, 9, 5);
      // Expenses on Sept 2 and Sept 4. Sept 1, 3, 5 are expense-free.
      final transactions = [
        createTx(DateTime(2026, 9, 2, 10)),
        createTx(DateTime(2026, 9, 4, 14)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: startDate,
          endDate: endDate,
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getQualifyingPeriods(
        type: StreakType.noSpend,
        startDate: startDate,
        endDate: endDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakDay.fromYmd(2026, 9, 1),
            const StreakDay.fromYmd(2026, 9, 3),
            const StreakDay.fromYmd(2026, 9, 5),
          ]);
        },
      );
    });

    test('extracts, deduplicates, and sorts open dates for appOpen', () async {
      final startDate = DateTime(2026, 9);
      final endDate = DateTime(2026, 9, 30);
      final openDates = [
        DateTime(2026, 9, 5, 10),
        DateTime(2026, 9, 2, 8),
        DateTime(2026, 9, 5, 16), // duplicate day
        DateTime(2026, 9, 10, 12),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: startDate,
          endDate: endDate,
        ),
      ).thenAnswer((_) async => Right(openDates));

      final result = await repository.getQualifyingPeriods(
        type: StreakType.appOpen,
        startDate: startDate,
        endDate: endDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakDay.fromYmd(2026, 9, 2),
            const StreakDay.fromYmd(2026, 9, 5),
            const StreakDay.fromYmd(2026, 9, 10),
          ]);
        },
      );
    });

    test('propagates repository failure as Left', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          Failure.localFailure(message: 'Failed to read records'),
        ),
      );

      final result = await repository.getQualifyingPeriods();

      expect(result.isLeft(), isTrue);
    });
  });
}
