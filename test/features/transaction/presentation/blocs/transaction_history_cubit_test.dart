import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/get_transactions_use_case.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_history_cubit.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_history_state.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

class FakeGetTransactionsParams extends Fake implements GetTransactionsParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetTransactionsParams());
  });

  late TransactionHistoryCubit cubit;
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;

  final tTransactionToday = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(50),
    description: StringSingleLine('Starbucks'),
    date: DateTime.now(),
    categoryUuid: UniqueId.generate(),
    type: TransactionType.expense,
  );

  final tTransactionYesterday = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(100),
    description: StringSingleLine('Salary'),
    date: DateTime.now().subtract(const Duration(days: 1)),
    categoryUuid: UniqueId.generate(),
    type: TransactionType.income,
  );

  final tTransactionMay14 = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(30),
    description: StringSingleLine('Uber'),
    date: DateTime(2024, 5, 14),
    categoryUuid: UniqueId.generate(),
    type: TransactionType.expense,
  );

  setUp(() {
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    cubit = TransactionHistoryCubit(mockGetTransactionsUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should have correct default values', () {
    expect(
      cubit.state.groupedTransactions,
      const <String, List<Transaction>>{},
    );
    expect(cubit.state.activeFlow, TransactionFlowType.all);
    expect(cubit.state.searchQuery, isNull);
    expect(cubit.state.activeCategoryId, isNull);
    expect(cubit.state.startDate, isNull);
    expect(cubit.state.endDate, isNull);
    expect(cubit.state.isLoading, isTrue);
    expect(cubit.state.error, isNull);
  });

  group('fetchTransactions', () {
    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should emit loading then grouped transactions when use case succeeds',
      build: () {
        when(() => mockGetTransactionsUseCase(any())).thenAnswer(
          (_) async => Right([
            tTransactionToday,
            tTransactionYesterday,
            tTransactionMay14,
          ]),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.error, 'error', isNull),
        isA<TransactionHistoryState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.groupedTransactions.keys, 'groups', [
              'Today',
              'Yesterday',
              'May 14, 2024',
            ])
            .having(
              (s) => s.groupedTransactions['Today']?.first,
              'Today transaction',
              tTransactionToday,
            )
            .having(
              (s) => s.groupedTransactions['Yesterday']?.first,
              'Yesterday transaction',
              tTransactionYesterday,
            )
            .having(
              (s) => s.groupedTransactions['May 14, 2024']?.first,
              'May 14 transaction',
              tTransactionMay14,
            ),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should emit loading then error when use case fails',
      build: () {
        when(() => mockGetTransactionsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Database error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.error, 'error', isNull),
        isA<TransactionHistoryState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', 'Database error'),
      ],
    );
  });

  group('filter updates', () {
    setUp(() {
      when(() => mockGetTransactionsUseCase(any())).thenAnswer(
        (_) async => Right([tTransactionToday]),
      );
    });

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'updateSearch should update search query and trigger fetch',
      build: () => cubit,
      act: (cubit) => cubit.updateSearch('Starbucks'),
      expect: () => [
        isA<TransactionHistoryState>()
            .having((s) => s.searchQuery, 'searchQuery', 'Starbucks')
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<TransactionHistoryState>()
            .having((s) => s.searchQuery, 'searchQuery', 'Starbucks')
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'updateFlowType should update active flow and trigger fetch',
      build: () => cubit,
      act: (cubit) => cubit.updateFlowType(TransactionFlowType.expense),
      expect: () => [
        isA<TransactionHistoryState>()
            .having(
              (s) => s.activeFlow,
              'activeFlow',
              TransactionFlowType.expense,
            )
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<TransactionHistoryState>()
            .having(
              (s) => s.activeFlow,
              'activeFlow',
              TransactionFlowType.expense,
            )
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'applyFilters should update date filters/category and trigger fetch',
      build: () => cubit,
      act: (cubit) => cubit.applyFilters(
        DateTime(2026, 7),
        DateTime(2026, 7, 5),
        'category-uuid',
      ),
      expect: () => [
        isA<TransactionHistoryState>()
            .having((s) => s.startDate, 'startDate', DateTime(2026, 7))
            .having((s) => s.endDate, 'endDate', DateTime(2026, 7, 5))
            .having(
              (s) => s.activeCategoryId,
              'activeCategoryId',
              'category-uuid',
            )
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<TransactionHistoryState>()
            .having((s) => s.startDate, 'startDate', DateTime(2026, 7))
            .having((s) => s.endDate, 'endDate', DateTime(2026, 7, 5))
            .having(
              (s) => s.activeCategoryId,
              'activeCategoryId',
              'category-uuid',
            )
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );
  });
}
