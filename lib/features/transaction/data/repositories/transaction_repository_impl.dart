import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_tracker/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:expense_tracker/features/transaction/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:injectable/injectable.dart';

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
  Future<Either<Failure, Unit>> updateTransaction(Transaction transaction) async {
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

      await _localDataSource.updateTransaction(
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

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? categoryId,
    TransactionFlowType flowType = TransactionFlowType.all,
  }) async {
    try {
      final models = await _localDataSource.getTransactions(
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        categoryId: categoryId,
        flowType: flowType.name,
      );
      final transactions = models.map((m) => m.toEntity()).toList();
      return Right(transactions);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}
