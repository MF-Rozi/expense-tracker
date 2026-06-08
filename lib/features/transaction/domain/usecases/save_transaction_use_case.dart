import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/features/transaction/domain/repositories/transaction_repository.dart';

@lazySingleton
class SaveTransactionUseCase extends UseCase<Unit, Transaction> {
  SaveTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Transaction params) {
    return _repository.saveTransaction(params);
  }
}
