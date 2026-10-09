import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:injectable/injectable.dart';

class GetUnderBudgetStatusParams extends Equatable {
  const GetUnderBudgetStatusParams({this.month});

  final DateTime? month;

  @override
  List<Object?> get props => [month];
}

@lazySingleton
class GetUnderBudgetStatusUseCase
    extends UseCase<UnderBudgetMonthStatus, GetUnderBudgetStatusParams> {
  const GetUnderBudgetStatusUseCase(this._streakRepository);

  final StreakRepository _streakRepository;

  @override
  Future<Either<Failure, UnderBudgetMonthStatus>> call(
    GetUnderBudgetStatusParams params,
  ) {
    return _streakRepository.getUnderBudgetStatus(month: params.month);
  }
}
