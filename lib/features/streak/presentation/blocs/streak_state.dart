import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';

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

  /// Returns the current active month or today's month if null.
  DateTime get displayMonth {
    final now = DateTime.now();
    return selectedMonth ?? DateTime(now.year, now.month);
  }

  StreakState copyWith({
    bool? isLoading,
    Streak? streak,
    DateTime? selectedMonth,
    Set<DateTime>? qualifyingDays,
    double? monthlyConsistencyRate,
    Option<Failure>? failureOption,
    StreakType? type,
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
      ];
}
