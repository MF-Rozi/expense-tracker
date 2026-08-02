import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_cubit.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TransactionFlowType.all);
  });

  late DashboardCubit cubit;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    cubit = DashboardCubit(mockRepository);
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

  group('DashboardCubit', () {
    test('initial state should have correct default values', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.totalBalance, 0);
      expect(cubit.state.totalIncome, 0);
      expect(cubit.state.totalExpense, 0);
      expect(cubit.state.recentTransactions, isEmpty);
      expect(cubit.state.failureOption, const None<Failure>());
    });

    blocTest<DashboardCubit, DashboardState>(
      'should emit loading and then success with correctly calculated sums '
      'when loading data succeeds',
      build: () {
        final transactions = [
          createTx(
            amount: 100,
            type: TransactionType.income,
            desc: 'Income 1',
          ),
          createTx(
            amount: 50,
            type: TransactionType.expense,
            desc: 'Expense 1',
          ),
          createTx(
            amount: 250,
            type: TransactionType.income,
            desc: 'Income 2',
          ),
          createTx(
            amount: 120,
            type: TransactionType.expense,
            desc: 'Expense 2',
          ),
        ];
        when(
          () => mockRepository.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            searchQuery: any(named: 'searchQuery'),
            categoryId: any(named: 'categoryId'),
            flowType: any(named: 'flowType'),
          ),
        ).thenAnswer((_) async => Right(transactions));
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
              4,
            )
            .having(
              (s) => s.failureOption,
              'failureOption',
              const None<Failure>(),
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'should strictly cap recentTransactions to 5 items '
      'when there are more than 5 transactions',
      build: () {
        final transactions = List.generate(
          10,
          (index) => createTx(
            amount: 10,
            type: TransactionType.expense,
            desc: 'Tx $index',
          ),
        );
        when(
          () => mockRepository.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            searchQuery: any(named: 'searchQuery'),
            categoryId: any(named: 'categoryId'),
            flowType: any(named: 'flowType'),
          ),
        ).thenAnswer((_) async => Right(transactions));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.recentTransactions.length,
              'recentTransactions length',
              5,
            )
            .having(
          (s) => s.recentTransactions
              .map((t) => t.description.getOrCrash())
              .toList(),
          'recentTransactions items',
          ['Tx 0', 'Tx 1', 'Tx 2', 'Tx 3', 'Tx 4'],
        ),
      ],
    );

    const failure = Failure.localFailure(message: 'Database error');

    blocTest<DashboardCubit, DashboardState>(
      'should emit loading and then failure when loading data fails',
      build: () {
        when(
          () => mockRepository.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            searchQuery: any(named: 'searchQuery'),
            categoryId: any(named: 'categoryId'),
            flowType: any(named: 'flowType'),
          ),
        ).thenAnswer((_) async => const Left(failure));
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
              const Some(failure),
            ),
      ],
    );
  });
}
