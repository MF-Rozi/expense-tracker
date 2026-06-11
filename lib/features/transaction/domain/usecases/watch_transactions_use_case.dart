import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/features/transaction/domain/repositories/transaction_repository.dart';

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
