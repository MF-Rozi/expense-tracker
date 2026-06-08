import 'package:dartz/dartz.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

abstract class TransactionRepository {
  Stream<Either<Failure, List<Transaction>>> watchTransactions();

  Future<Either<Failure, Unit>> saveTransaction(Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(UniqueId transactionUuid);
}
