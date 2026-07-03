import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:expense_tracker/features/transaction/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionLocalDataSource extends Mock
    implements TransactionLocalDataSource {}

class MockCategoryLocalDataSource extends Mock
    implements CategoryLocalDataSource {}

// Fallback for mocktail
class FakeTransactionModel extends Fake implements TransactionModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransactionModel());
  });

  late TransactionRepositoryImpl repository;
  late MockTransactionLocalDataSource mockTransactionDataSource;
  late MockCategoryLocalDataSource mockCategoryDataSource;

  setUp(() {
    mockTransactionDataSource = MockTransactionLocalDataSource();
    mockCategoryDataSource = MockCategoryLocalDataSource();
    repository = TransactionRepositoryImpl(
      mockTransactionDataSource,
      mockCategoryDataSource,
    );
  });

  final tCategoryUuid = UniqueId.generate();
  final tTransaction = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(100),
    description: StringSingleLine('Test Transaction'),
    date: DateTime.now(),
    categoryUuid: tCategoryUuid,
    type: TransactionType.expense,
  );

  group('saveTransaction', () {
    test(
      'should return Left(Failure.localFailure) when the referenced '
      'category does not exist',
      () async {
        // arrange
        when(() => mockCategoryDataSource.getCategoryByUuid(any()))
            .thenAnswer((_) async => null);

        // act
        final result = await repository.saveTransaction(tTransaction);

        // assert
        expect(
          result,
          const Left<Failure, Unit>(
            Failure.localFailure(
              message: 'Referenced category structure does not exist.',
            ),
          ),
        );
        verify(
          () => mockCategoryDataSource.getCategoryByUuid(
            tCategoryUuid.getOrCrash(),
          ),
        ).called(1);
        verifyZeroInteractions(mockTransactionDataSource);
      },
    );

    test(
      'should return Right(unit) and call saveTransaction on local '
      'data source when category exists',
      () async {
        // arrange
        final tCategoryModel = CategoryModel()
          ..uuid = tCategoryUuid.getOrCrash()
          ..name = 'Test Category'
          ..isSynced = false
          ..updatedAt = DateTime.now();

        when(() => mockCategoryDataSource.getCategoryByUuid(any()))
            .thenAnswer((_) async => tCategoryModel);
        when(() => mockTransactionDataSource.saveTransaction(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.saveTransaction(tTransaction);

        // assert
        expect(result, const Right<Failure, Unit>(unit));
        verify(
          () => mockCategoryDataSource.getCategoryByUuid(
            tCategoryUuid.getOrCrash(),
          ),
        ).called(1);
        verify(() => mockTransactionDataSource.saveTransaction(any()))
            .called(1);
      },
    );
  });
}
