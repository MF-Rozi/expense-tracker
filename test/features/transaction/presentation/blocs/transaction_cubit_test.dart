import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/create_transaction_use_case.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/update_transaction_use_case.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_cubit.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_state.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateTransactionUseCase extends Mock
    implements CreateTransactionUseCase {}

class MockUpdateTransactionUseCase extends Mock
    implements UpdateTransactionUseCase {}

// Fallback for mocktail
class FakeTransaction extends Fake implements Transaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  late TransactionCubit cubit;
  late MockCreateTransactionUseCase mockCreateTransactionUseCase;
  late MockUpdateTransactionUseCase mockUpdateTransactionUseCase;

  setUp(() {
    mockCreateTransactionUseCase = MockCreateTransactionUseCase();
    mockUpdateTransactionUseCase = MockUpdateTransactionUseCase();
    cubit = TransactionCubit(
      mockCreateTransactionUseCase,
      mockUpdateTransactionUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be TransactionState with initial values', () {
    expect(cubit.state.rawExpression, '0');
    expect(cubit.state.parsedAmount, 0.0);
    expect(cubit.state.status, TransactionFormStatus.initial);
  });

  blocTest<TransactionCubit, TransactionState>(
    'should update rawExpression and parsedAmount when '
    'updateExpression is called',
    build: () => cubit,
    act: (cubit) => cubit.updateExpression('5'),
    expect: () => [
      isA<TransactionState>()
          .having((s) => s.rawExpression, 'rawExpression', '5')
          .having((s) => s.parsedAmount, 'parsedAmount', 5.0),
    ],
  );

  blocTest<TransactionCubit, TransactionState>(
    'should correctly handle multiple updateExpression calls',
    build: () => cubit,
    act: (cubit) => cubit
      ..updateExpression('1')
      ..updateExpression('0')
      ..updateExpression('+')
      ..updateExpression('2'),
    expect: () => [
      isA<TransactionState>()
          .having((s) => s.rawExpression, 'rawExpression', '1'),
      isA<TransactionState>()
          .having((s) => s.rawExpression, 'rawExpression', '10'),
      isA<TransactionState>()
          .having((s) => s.rawExpression, 'rawExpression', '10+'),
      isA<TransactionState>()
          .having((s) => s.rawExpression, 'rawExpression', '10+2')
          .having((s) => s.parsedAmount, 'parsedAmount', 12.0),
    ],
  );

  final tCategory = Category(
    uuid: UniqueId.generate(),
    name: StringSingleLine('Food'),
    isSynced: false,
    updatedAt: DateTime.now(),
  );

  blocTest<TransactionCubit, TransactionState>(
    'should emit loading and success when submitTransaction (create) '
    'is successful',
    build: () {
      when(() => mockCreateTransactionUseCase(any()))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));
      return cubit;
    },
    act: (cubit) => cubit
      ..selectCategory(tCategory)
      ..updateExpression('100')
      ..submitTransaction(),
    expect: () => [
      isA<TransactionState>()
          .having((s) => s.selectedCategory, 'category', tCategory),
      isA<TransactionState>()
          .having((s) => s.rawExpression, 'rawExpression', '100')
          .having((s) => s.parsedAmount, 'parsedAmount', 100.0),
      isA<TransactionState>()
          .having((s) => s.status, 'status', TransactionFormStatus.loading),
      isA<TransactionState>()
          .having((s) => s.status, 'status', TransactionFormStatus.success),
    ],
    verify: (_) {
      verify(() => mockCreateTransactionUseCase(any())).called(1);
      verifyZeroInteractions(mockUpdateTransactionUseCase);
    },
  );

  final tExistingTransaction = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(250),
    description: StringSingleLine('Rent'),
    date: DateTime.now(),
    categoryUuid: tCategory.uuid,
    type: TransactionType.expense,
  );

  blocTest<TransactionCubit, TransactionState>(
    'should load existing transaction into state and '
    'submitTransaction (update) successfully',
    build: () {
      when(() => mockUpdateTransactionUseCase(any()))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));
      return cubit;
    },
    act: (cubit) => cubit
      ..loadExistingTransaction(tExistingTransaction, tCategory)
      ..submitTransaction(),
    expect: () => [
      isA<TransactionState>()
          .having(
            (s) => s.existingTransactionId,
            'existingTransactionId',
            tExistingTransaction.uuid,
          )
          .having((s) => s.rawExpression, 'rawExpression', '250')
          .having((s) => s.parsedAmount, 'parsedAmount', 250.0)
          .having((s) => s.selectedCategory, 'category', tCategory)
          .having((s) => s.description, 'description', 'Rent')
          .having((s) => s.type, 'type', TransactionType.expense),
      isA<TransactionState>()
          .having((s) => s.status, 'status', TransactionFormStatus.loading),
      isA<TransactionState>()
          .having((s) => s.status, 'status', TransactionFormStatus.success),
    ],
    verify: (_) {
      verify(() => mockUpdateTransactionUseCase(any())).called(1);
      verifyZeroInteractions(mockCreateTransactionUseCase);
    },
  );
}
