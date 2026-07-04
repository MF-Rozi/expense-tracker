import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetTransactionsUseCase
    extends UseCase<List<Transaction>, GetTransactionsParams> {
  GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(GetTransactionsParams params) {
    return _repository.getTransactions(
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
      categoryId: params.categoryId,
      flowType: params.flowType,
    );
  }
}

class GetTransactionsParams extends Equatable {
  const GetTransactionsParams({
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.categoryId,
    this.flowType = TransactionFlowType.all,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final String? categoryId;
  final TransactionFlowType flowType;

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        searchQuery,
        categoryId,
        flowType,
      ];
}
