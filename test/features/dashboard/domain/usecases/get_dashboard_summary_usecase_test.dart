import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late GetDashboardSummaryUseCase useCase;

  // Fixed deterministic anchor: Sept 21, 2026
  final fixedNow = DateTime(2026, 9, 21, 15, 30);
  final tCategoryUuid = UniqueId.generate();

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetDashboardSummaryUseCase(mockRepository);
  });

  Transaction makeTx({
    required double amount,
    required TransactionType type,
    required DateTime date,
    String desc = 'Tx',
  }) {
    return Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(amount),
      description: StringSingleLine(desc),
      date: date,
      categoryUuid: tCategoryUuid,
      type: type,
    );
  }

  test(
    'returns 5 monthly points ordered chronologically ending in current month',
    () async {
      when(() => mockRepository.getTransactions())
          .thenAnswer((_) async => const Right([]));

      final result = await useCase.executeWithDate(fixedNow);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          final points = summary.wealthTrajectory.points;
          expect(points.length, 5);
          // Should be May, Jun, Jul, Aug, Sep 2026
          expect(points[0].month, DateTime(2026, 5));
          expect(points[0].isCurrentMonth, isFalse);

          expect(points[1].month, DateTime(2026, 6));
          expect(points[1].isCurrentMonth, isFalse);

          expect(points[2].month, DateTime(2026, 7));
          expect(points[2].isCurrentMonth, isFalse);

          expect(points[3].month, DateTime(2026, 8));
          expect(points[3].isCurrentMonth, isFalse);

          expect(points[4].month, DateTime(2026, 9));
          expect(points[4].isCurrentMonth, isTrue);

          expect(
            summary.wealthTrajectory.headlineDescription,
            'No transaction data yet.',
          );
        },
      );
    },
  );

  test(
    'computes positive net worth growth when balance increases '
    'month-over-month',
    () async {
      // August had cumulative net worth of 1,000,000
      // September added 200,000 net income -> cumulative 1,200,000 (+20%)
      final transactions = [
        makeTx(
          amount: 1000000,
          type: TransactionType.income,
          date: DateTime(2026, 8, 10),
        ),
        makeTx(
          amount: 500000,
          type: TransactionType.income,
          date: DateTime(2026, 9, 5),
        ),
        makeTx(
          amount: 300000,
          type: TransactionType.expense,
          date: DateTime(2026, 9, 12),
        ),
      ];

      when(() => mockRepository.getTransactions())
          .thenAnswer((_) async => Right(transactions));

      final result = await useCase.executeWithDate(fixedNow);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          final wt = summary.wealthTrajectory;
          expect(wt.points[3].netWorth, 1000000.0);
          expect(wt.points[4].netWorth, 1200000.0);
          expect(wt.growthPercentage, closeTo(20.0, 0.01));
          expect(
            wt.headlineDescription,
            'Your net worth increased by 20.0% this month.',
          );

          // Current month aggregates
          expect(summary.totalIncome, 500000.0);
          expect(summary.totalExpense, 300000.0);
          expect(summary.totalBalance, 200000.0);
        },
      );
    },
  );

  test(
    'computes negative net worth growth when balance decreases '
    'month-over-month',
    () async {
      // August cumulative net worth 1,000,000
      // September spent 200,000 with no income -> cumulative 800,000 (-20%)
      final transactions = [
        makeTx(
          amount: 1000000,
          type: TransactionType.income,
          date: DateTime(2026, 8, 10),
        ),
        makeTx(
          amount: 200000,
          type: TransactionType.expense,
          date: DateTime(2026, 9, 2),
        ),
      ];

      when(() => mockRepository.getTransactions())
          .thenAnswer((_) async => Right(transactions));

      final result = await useCase.executeWithDate(fixedNow);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          final wt = summary.wealthTrajectory;
          expect(wt.points[3].netWorth, 1000000.0);
          expect(wt.points[4].netWorth, 800000.0);
          expect(wt.growthPercentage, closeTo(-20.0, 0.01));
          expect(
            wt.headlineDescription,
            'Your net worth decreased by 20.0% this month.',
          );
        },
      );
    },
  );

  test('handles zero previous month net worth gracefully', () async {
    // All transactions occurred in current month (September)
    final transactions = [
      makeTx(
        amount: 500000,
        type: TransactionType.income,
        date: DateTime(2026, 9, 10),
      ),
    ];

    when(() => mockRepository.getTransactions())
        .thenAnswer((_) async => Right(transactions));

    final result = await useCase.executeWithDate(fixedNow);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (summary) {
        final wt = summary.wealthTrajectory;
        expect(wt.points[3].netWorth, 0.0);
        expect(wt.points[4].netWorth, 500000.0);
        expect(wt.growthPercentage, isNull);
        expect(
          wt.headlineDescription,
          'First month of positive net worth!',
        );
      },
    );
  });

  test('correctly orders and limits top 5 recent transactions', () async {
    final transactions = List.generate(
      8,
      (i) => makeTx(
        amount: (i + 1) * 1000,
        type: TransactionType.expense,
        date: DateTime(2026, 9, i + 1),
        desc: 'Tx $i',
      ),
    );

    when(() => mockRepository.getTransactions())
        .thenAnswer((_) async => Right(transactions));

    final result = await useCase.executeWithDate(fixedNow);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (summary) {
        expect(summary.recentTransactions.length, 5);
        // Most recent first: Tx 7, 6, 5, 4, 3
        expect(
          summary.recentTransactions
              .map((t) => t.description.getOrCrash())
              .toList(),
          ['Tx 7', 'Tx 6', 'Tx 5', 'Tx 4', 'Tx 3'],
        );
      },
    );
  });

  test('propagates repository failure as Left(Failure)', () async {
    const failure = Failure.localFailure(message: 'Database unavailable');
    when(() => mockRepository.getTransactions()).thenAnswer(
      (_) async => const Left<Failure, List<Transaction>>(failure),
    );

    final result = await useCase.executeWithDate(fixedNow);

    expect(result, const Left<Failure, DashboardSummary>(failure));
  });
}
