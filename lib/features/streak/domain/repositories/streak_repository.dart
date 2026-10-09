import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';

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

  /// Retrieves category overrun flags for [month] (defaulting to current
  /// month).
  Future<Either<Failure, List<CategoryOverrunFlag>>> getCategoryOverrunFlags({
    DateTime? month,
  });

  /// Evaluates whether the current in-progress month is on track (spent <=
  /// budget).
  Future<Either<Failure, bool>> isCurrentMonthOnTrack({
    DateTime? referenceDate,
  });

  /// Retrieves comprehensive monthly budget status and flags for [month].
  Future<Either<Failure, UnderBudgetMonthStatus>> getUnderBudgetStatus({
    DateTime? month,
  });
}
