import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/features/transaction/domain/entities/transaction_type.dart';
import 'package:template/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:template/features/transaction/domain/usecases/save_transaction_use_case.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

// Fallback for mocktail
class FakeTransaction extends Fake implements Transaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  late SaveTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = SaveTransactionUseCase(mockRepository);
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
    'should call saveTransaction on the repository with the provided '
    'transaction',
    () async {
      // arrange
      when(() => mockRepository.saveTransaction(any()))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));

      // act
      final result = await useCase(tTransaction);

      // assert
      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.saveTransaction(tTransaction)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
