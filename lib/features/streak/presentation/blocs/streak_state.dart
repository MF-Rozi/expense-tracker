import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';

/// State representation for the Streaks page.
class StreakState extends Equatable {
  const StreakState({
    this.isLoading = true,
    this.streak = const Streak.empty(),
    this.selectedMonth,
    this.qualifyingDays = const {},
    this.monthlyConsistencyRate = 0.0,
    this.failureOption = const None(),
    this.type = StreakType.tracking,
    this.underBudgetStatus,
  });

  /// Factory creating initial state for a given [referenceDate] and [type].
  factory StreakState.initial([
    DateTime? referenceDate,
    StreakType type = StreakType.tracking,
  ]) {
    final now = referenceDate ?? DateTime.now();
    return StreakState(
      selectedMonth: DateTime(now.year, now.month),
      type: type,
    );
  }

  final bool isLoading;
  final Streak streak;
  final DateTime? selectedMonth;
  final Set<DateTime> qualifyingDays;
  final double monthlyConsistencyRate;
  final Option<Failure> failureOption;
  final StreakType type;
  final UnderBudgetMonthStatus? underBudgetStatus;

  /// Returns the current active month or today's month if null.
  DateTime get displayMonth {
    final now = DateTime.now();
    return selectedMonth ?? DateTime(now.year, now.month);
  }

  /// Whether current in-progress month is within budget.
  bool get isOnTrack =>
      underBudgetStatus?.isOnTrack ?? (streak.isCurrentMonthOnTrack ?? true);

  /// Overrun flags for the selected month (R17).
  List<CategoryOverrunFlag> get categoryOverrunFlags =>
      underBudgetStatus?.overrunFlags ?? const [];

  /// Total budget for selected month.
  double get currentMonthBudget => underBudgetStatus?.totalBudget ?? 0.0;

  /// Total spent in selected month.
  double get currentMonthExpense => underBudgetStatus?.totalSpent ?? 0.0;

  StreakState copyWith({
    bool? isLoading,
    Streak? streak,
    DateTime? selectedMonth,
    Set<DateTime>? qualifyingDays,
    double? monthlyConsistencyRate,
    Option<Failure>? failureOption,
    StreakType? type,
    UnderBudgetMonthStatus? underBudgetStatus,
  }) {
    return StreakState(
      isLoading: isLoading ?? this.isLoading,
      streak: streak ?? this.streak,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      qualifyingDays: qualifyingDays ?? this.qualifyingDays,
      monthlyConsistencyRate:
          monthlyConsistencyRate ?? this.monthlyConsistencyRate,
      failureOption: failureOption ?? this.failureOption,
      type: type ?? this.type,
      underBudgetStatus: underBudgetStatus ?? this.underBudgetStatus,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        streak,
        selectedMonth,
        qualifyingDays,
        monthlyConsistencyRate,
        failureOption,
        type,
        underBudgetStatus,
      ];
}
