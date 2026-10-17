import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetQualifyingPeriodsUseCase
    extends UseCase<List<StreakPeriod>, GetQualifyingPeriodsParams> {
  const GetQualifyingPeriodsUseCase(this._repository);

  final StreakRepository _repository;

  @override
  Future<Either<Failure, List<StreakPeriod>>> call(
    GetQualifyingPeriodsParams params,
  ) {
    return _repository.getQualifyingPeriods(
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetQualifyingPeriodsParams extends Equatable {
  const GetQualifyingPeriodsParams({
    this.type = StreakType.tracking,
    this.startDate,
    this.endDate,
  });

  final StreakType type;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [type, startDate, endDate];
}
