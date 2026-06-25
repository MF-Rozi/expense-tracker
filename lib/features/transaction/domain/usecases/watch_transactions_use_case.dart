import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WatchTransactionsUseCase
    extends StreamUseCase<List<Transaction>, NoParams> {
  WatchTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Stream<Either<Failure, List<Transaction>>> call(NoParams params) {
    return _repository.watchTransactions();
  }
}
