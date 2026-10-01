import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';

/// Contract for calculating and querying streak metrics and qualifying periods.
abstract class StreakRepository {
  /// Calculates the current and best streak for [type] as of [referenceDate].
  ///
  /// If [referenceDate] is omitted, evaluation defaults to current date/time.
  Future<Either<Failure, Streak>> getStreak({
    StreakType type = StreakType.tracking,
    DateTime? referenceDate,
  });

  /// Retrieves all discrete qualifying periods for [type] within the optional
  /// range [startDate]..[endDate].
  Future<Either<Failure, List<StreakPeriod>>> getQualifyingPeriods({
    StreakType type = StreakType.tracking,
    DateTime? startDate,
    DateTime? endDate,
  });
}
