import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/wealth_trajectory.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_cubit.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDashboardSummaryUseCase extends Mock
    implements GetDashboardSummaryUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetDashboardSummaryUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockUseCase = MockGetDashboardSummaryUseCase();
    cubit = DashboardCubit(mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  final tCategoryUuid = UniqueId.generate();

  Transaction createTx({
    required double amount,
    required TransactionType type,
    String desc = 'Test',
  }) {
    return Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(amount),
      description: StringSingleLine(desc),
      date: DateTime.now(),
      categoryUuid: tCategoryUuid,
      type: type,
    );
  }

  final tTrajectory = WealthTrajectory(
    points: [
      TrajectoryPoint(
        month: DateTime(2026, 5),
        netWorth: 100,
        isCurrentMonth: false,
      ),
      TrajectoryPoint(
        month: DateTime(2026, 6),
        netWorth: 200,
        isCurrentMonth: false,
      ),
      TrajectoryPoint(
        month: DateTime(2026, 7),
        netWorth: 300,
        isCurrentMonth: false,
      ),
      TrajectoryPoint(
        month: DateTime(2026, 8),
        netWorth: 400,
        isCurrentMonth: false,
      ),
      TrajectoryPoint(
        month: DateTime(2026, 9),
        netWorth: 500,
        isCurrentMonth: true,
      ),
    ],
    growthPercentage: 25,
    headlineDescription: 'Your net worth increased by 25.0% this month.',
  );

  final tSummary = DashboardSummary(
    totalBalance: 180,
    totalIncome: 350,
    totalExpense: 170,
    recentTransactions: [
      createTx(amount: 100, type: TransactionType.income, desc: 'Income 1'),
      createTx(amount: 50, type: TransactionType.expense, desc: 'Expense 1'),
    ],
    wealthTrajectory: tTrajectory,
  );

  group('DashboardCubit', () {
    test('initial state should have correct default values', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.totalBalance, 0);
      expect(cubit.state.totalIncome, 0);
      expect(cubit.state.totalExpense, 0);
      expect(cubit.state.recentTransactions, isEmpty);
      expect(cubit.state.wealthTrajectory, isNull);
      expect(cubit.state.failureOption, const None<Failure>());
    });

    blocTest<DashboardCubit, DashboardState>(
      'should emit loading and then success with summary data when load '
      'succeeds',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => Right(tSummary));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having(
              (s) => s.failureOption,
              'failureOption',
              const None<Failure>(),
            ),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.totalIncome, 'totalIncome', 350)
            .having((s) => s.totalExpense, 'totalExpense', 170)
            .having((s) => s.totalBalance, 'totalBalance', 180)
            .having(
              (s) => s.recentTransactions.length,
              'recentTransactions length',
              2,
            )
            .having(
              (s) => s.wealthTrajectory,
              'wealthTrajectory',
              tTrajectory,
            )
            .having(
              (s) => s.failureOption,
              'failureOption',
              const None<Failure>(),
            ),
      ],
    );

    const failure = Failure.localFailure(message: 'Database error');

    blocTest<DashboardCubit, DashboardState>(
      'should emit loading and then failure when loading data fails',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const Left(failure));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having(
              (s) => s.failureOption,
              'failureOption',
              const None<Failure>(),
            ),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.failureOption,
              'failureOption',
              some(failure),
            ),
      ],
    );
  });
}
