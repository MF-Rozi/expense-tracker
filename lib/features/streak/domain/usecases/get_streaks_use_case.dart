import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetStreaksUseCase extends UseCase<Streak, GetStreaksParams> {
  const GetStreaksUseCase(this._repository);

  final StreakRepository _repository;

  @override
  Future<Either<Failure, Streak>> call(GetStreaksParams params) {
    return _repository.getStreak(
      type: params.type,
      referenceDate: params.referenceDate,
    );
  }
}

class GetStreaksParams extends Equatable {
  const GetStreaksParams({
    this.type = StreakType.tracking,
    this.referenceDate,
  });

  final StreakType type;
  final DateTime? referenceDate;

  @override
  List<Object?> get props => [type, referenceDate];
}
