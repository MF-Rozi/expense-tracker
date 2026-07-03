import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';

abstract class TransactionRepository {
  Stream<Either<Failure, List<Transaction>>> watchTransactions();

  Future<Either<Failure, Unit>> saveTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(UniqueId transactionUuid);
}
