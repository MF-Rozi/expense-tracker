import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/get_transactions_use_case.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TransactionFlowType.all);
  });

  late GetTransactionsUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  final tTransactionsList = [
    Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(100),
      description: StringSingleLine('Test Transaction 1'),
      date: DateTime.now(),
      categoryUuid: UniqueId.generate(),
      type: TransactionType.expense,
    ),
    Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(200),
      description: StringSingleLine('Test Transaction 2'),
      date: DateTime.now(),
      categoryUuid: UniqueId.generate(),
      type: TransactionType.income,
    ),
  ];

  group('GetTransactionsUseCase', () {
    test(
      'should delegate parameter filtering to repository and return the transactions',
      () async {
        final tStartDate = DateTime(2026, 1, 1);
        final tEndDate = DateTime(2026, 1, 31);
        const tSearchQuery = 'Test';
        const tCategoryId = 'cat-123';
        const tFlowType = TransactionFlowType.expense;

        final params = GetTransactionsParams(
          startDate: tStartDate,
          endDate: tEndDate,
          searchQuery: tSearchQuery,
          categoryId: tCategoryId,
          flowType: tFlowType,
        );

        // arrange
        when(
          () => mockRepository.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            searchQuery: any(named: 'searchQuery'),
            categoryId: any(named: 'categoryId'),
            flowType: any(named: 'flowType'),
          ),
        ).thenAnswer((_) async => Right(tTransactionsList));

        // act
        final result = await useCase(params);

        // assert
        expect(result, Right(tTransactionsList));
        verify(
          () => mockRepository.getTransactions(
            startDate: tStartDate,
            endDate: tEndDate,
            searchQuery: tSearchQuery,
            categoryId: tCategoryId,
            flowType: tFlowType,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should support equality comparison for params', () {
      final tStartDate = DateTime(2026, 1, 1);
      final params1 = GetTransactionsParams(
        startDate: tStartDate,
        flowType: TransactionFlowType.all,
      );
      final params2 = GetTransactionsParams(
        startDate: tStartDate,
        flowType: TransactionFlowType.all,
      );

      expect(params1, equals(params2));
    });
  });
}
