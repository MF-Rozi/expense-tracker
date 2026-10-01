import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late MockTransactionRepository mockTxRepo;
  late MockLocalStorage mockStorage;
  late StreakRepositoryImpl repository;

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    mockStorage = MockLocalStorage();
    repository = StreakRepositoryImpl(mockTxRepo, mockStorage);

    // Default storage mocks
    when(() => mockStorage.getStreakWindowDays()).thenAnswer((_) async => 3);
    when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 3);
    when(() => mockStorage.getAppOpenCadenceDays()).thenAnswer((_) async => 7);
  });

  Transaction createTx(DateTime date) {
    return Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(100),
      description: StringSingleLine('Test transaction'),
      date: date,
      categoryUuid: UniqueId.generate(),
      type: TransactionType.expense,
    );
  }

  group('StreakRepositoryImpl.getStreak', () {
    test(
        'Transactions on scattered days within window -> '
        'single run, calendar-span length', () async {
      // Evaluation date: Sept 25, 2026.
      // Transactions on Sept 20, Sept 22, Sept 25.
      // Window is 3:
      // Sept 20 -> 22 diff is 2 (<= 3).
      // Sept 22 -> 25 diff is 3 (<= 3).
      // Continuous run from Sept 20 to Sept 25 inclusive = 6 days.
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
      // Evaluation date: Sept 22, 2026.
      // Cluster 1 (7 days): Sept 1 to Sept 7 (days 1, 4, 7 with window 3).
      // Gap: Sept 7 to Sept 20 (13 days > window 3).
      // Cluster 2 (3 days): Sept 20, 21, 22 (today).
      final refDate = DateTime(2026, 9, 22, 10);
      final transactions = [
        // Cluster 1: run spanning Sept 1 to Sept 7 = 7 days
        createTx(DateTime(2026, 9, 1, 8)),
        createTx(DateTime(2026, 9, 4, 12)),
        createTx(DateTime(2026, 9, 7, 18)),
        // Cluster 2: run spanning Sept 20 to Sept 22 = 3 days
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

    test('Config override: window 1 behaves as strict daily streak', () async {
      // Window overridden to 1
      when(() => mockStorage.getStreakWindowDays()).thenAnswer((_) async => 1);

      // Transactions on Sept 20 and Sept 22 (today).
      // Gap is 2 > 1 -> ends the run on Sept 20.
      final refDate = DateTime(2026, 9, 22, 14);
      final transactions = [
        createTx(DateTime(2026, 9, 20, 9)),
        createTx(DateTime(2026, 9, 22, 11)),
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
          // Fresh run on Sept 22 of length 1 (warming up because minimum is 3)
          expect(streak.length, 1);
          expect(streak.status, StreakStatus.warmingUp);
          expect(streak.bestLength, 1);
        },
      );
    });

    test('Repository failure from TransactionRepository propagates as Left',
        () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          Failure.serverFailure(message: 'Database query error'),
        ),
      );

      final result = await repository.getStreak();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(
            failure,
            const Failure.serverFailure(message: 'Database query error'),
          );
        },
        (_) => fail('Expected Left'),
      );
    });

    test('No transactions at all -> empty streak entity', () async {
      final refDate = DateTime(2026, 9, 28, 12);
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

    test('Returns Left for unsupported streak types in phase 1', () async {
      final result = await repository.getStreak(type: StreakType.noSpend);

      expect(result.isLeft(), isTrue);
    });
  });

  group('StreakRepositoryImpl.getQualifyingPeriods', () {
    test('extracts, deduplicates, and sorts qualifying dates', () async {
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
