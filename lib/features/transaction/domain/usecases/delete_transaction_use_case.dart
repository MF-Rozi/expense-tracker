import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

@lazySingleton
class DeleteTransactionUseCase extends UseCase<Unit, DeleteTransactionParams> {
  DeleteTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteTransactionParams params) {
    return _repository.deleteTransaction(params.uuid);
  }
}

class DeleteTransactionParams extends Equatable {
  const DeleteTransactionParams(this.uuid);

  final UniqueId uuid;

  @override
  List<Object?> get props => [uuid];
}
