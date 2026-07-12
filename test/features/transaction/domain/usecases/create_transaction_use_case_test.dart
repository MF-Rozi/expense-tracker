import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/create_transaction_use_case.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  late CreateTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CreateTransactionUseCase(mockRepository);
  });

  final tTransaction = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(100),
    description: StringSingleLine('Test Transaction'),
    date: DateTime.now(),
    categoryUuid: UniqueId.generate(),
    type: TransactionType.expense,
  );

  test(
    'should call saveTransaction on the repository with the provided transaction',
    () async {
      when(() => mockRepository.saveTransaction(any()))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));

      final result = await useCase(tTransaction);

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.saveTransaction(tTransaction)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
