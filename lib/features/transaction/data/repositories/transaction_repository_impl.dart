import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/features/category/data/datasources/category_local_data_source.dart';
import 'package:template/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:template/features/transaction/data/models/transaction_model.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(
    this._localDataSource,
    this._categoryDataSource,
  );

  final TransactionLocalDataSource _localDataSource;
  final CategoryLocalDataSource _categoryDataSource;

  @override
  Stream<Either<Failure, List<Transaction>>> watchTransactions() {
    return _localDataSource.watchTransactions().map(
          (models) => Right(
            models.map((m) => m.toEntity()).toList(),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> saveTransaction(Transaction transaction) async {
    try {
      // Crucial Integrity Rule: Check if the referenced category exists
      final category = await _categoryDataSource.getCategoryByUuid(
        transaction.categoryUuid.getOrCrash(),
      );

      if (category == null) {
        return const Left(
          Failure.localFailure(
            message: 'Referenced category structure does not exist.',
          ),
        );
      }

      await _localDataSource.saveTransaction(
        TransactionModel.fromEntity(transaction),
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(
    UniqueId transactionUuid,
  ) async {
    try {
      await _localDataSource.deleteTransaction(transactionUuid.getOrCrash());
      return const Right(unit);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}
