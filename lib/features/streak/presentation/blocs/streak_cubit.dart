import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_qualifying_periods_use_case.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_streaks_use_case.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_under_budget_status_use_case.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_state.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/watch_transactions_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit managing state for the Streaks page.
@injectable
class StreakCubit extends Cubit<StreakState> {
  StreakCubit(
    this._getStreaksUseCase,
    this._getQualifyingPeriodsUseCase,
    this._watchTransactionsUseCase, {
    GetUnderBudgetStatusUseCase? getUnderBudgetStatusUseCase,
  })  : _getUnderBudgetStatusUseCase = getUnderBudgetStatusUseCase,
        _clock = DateTime.now,
        super(StreakState.initial()) {
    _init();
  }

  /// Factory constructor for deterministic testing.
  StreakCubit.test({
    required GetStreaksUseCase getStreaksUseCase,
    required GetQualifyingPeriodsUseCase getQualifyingPeriodsUseCase,
    WatchTransactionsUseCase? watchTransactionsUseCase,
    GetUnderBudgetStatusUseCase? getUnderBudgetStatusUseCase,
    DateTime Function()? clock,
    StreakType initialType = StreakType.tracking,
  })  : _getStreaksUseCase = getStreaksUseCase,
        _getQualifyingPeriodsUseCase = getQualifyingPeriodsUseCase,
        _watchTransactionsUseCase = watchTransactionsUseCase,
        _getUnderBudgetStatusUseCase = getUnderBudgetStatusUseCase,
        _clock = clock ?? DateTime.now,
        super(StreakState.initial(clock?.call(), initialType)) {
    _init();
  }

  final GetStreaksUseCase _getStreaksUseCase;
  final GetQualifyingPeriodsUseCase _getQualifyingPeriodsUseCase;
  final WatchTransactionsUseCase? _watchTransactionsUseCase;
  final GetUnderBudgetStatusUseCase? _getUnderBudgetStatusUseCase;
  final DateTime Function() _clock;

  StreamSubscription<dynamic>? _txSubscription;

  void _init() {
    _txSubscription = _watchTransactionsUseCase?.call(NoParams()).listen(
      (result) {
        result.fold(
          (_) {},
          (_) {
            load(showLoading: false);
          },
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _txSubscription?.cancel();
    return super.close();
  }

  /// Switches the active streak type and reloads data.
  Future<void> selectType(StreakType type) async {
    if (state.type == type && !state.isLoading) return;
    await load(type: type);
  }

  /// Loads streak data and qualifying days for [month] (defaulting to current).
  Future<void> load({
    DateTime? month,
    bool showLoading = true,
    StreakType? type,
  }) async {
    final now = _clock();
    final targetMonth = month ?? state.selectedMonth ?? now;
    final normalizedMonth = DateTime(targetMonth.year, targetMonth.month);
    final activeType = type ?? state.type;

    if (showLoading) {
      emit(
        state.copyWith(
          isLoading: true,
          selectedMonth: normalizedMonth,
          type: activeType,
        ),
      );
    }

    final startDate = DateTime(normalizedMonth.year, normalizedMonth.month);
    final endDate = DateTime(
      normalizedMonth.year,
      normalizedMonth.month + 1,
      0,
    );

    final underBudgetFuture = (activeType == StreakType.underBudget &&
            _getUnderBudgetStatusUseCase != null)
        ? _getUnderBudgetStatusUseCase(
            GetUnderBudgetStatusParams(month: normalizedMonth),
          )
        : Future<Either<Failure, UnderBudgetMonthStatus>?>.value();

    final results = await Future.wait([
      _getStreaksUseCase(
        GetStreaksParams(
          type: activeType,
          referenceDate: now,
        ),
      ),
      _getQualifyingPeriodsUseCase(
        GetQualifyingPeriodsParams(
          type: activeType,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
      underBudgetFuture,
    ]);

    final streakResult = results[0]! as Either<Failure, Streak>;
    final periodsResult = results[1]! as Either<Failure, List<StreakPeriod>>;
    final underBudgetResult =
        results[2] as Either<Failure, UnderBudgetMonthStatus>?;

    streakResult.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            type: activeType,
            failureOption: some(failure),
          ),
        );
      },
      (streak) {
        periodsResult.fold(
          (failure) {
            emit(
              state.copyWith(
                isLoading: false,
                type: activeType,
                streak: streak,
                failureOption: some(failure),
              ),
            );
          },
          (periods) {
            final qualifyingDays = periods
                .whereType<StreakDay>()
                .map((p) => DateTime(p.year, p.month, p.day))
                .toSet();

            final consistencyRate = activeType == StreakType.underBudget
                ? streak.consistencyRate
                : _calculateMonthlyConsistency(
                    targetMonth: normalizedMonth,
                    qualifyingDays: qualifyingDays,
                    now: now,
                  );

            final underBudgetStatus =
                underBudgetResult?.fold((_) => null, (status) => status);

            emit(
              state.copyWith(
                isLoading: false,
                type: activeType,
                streak: streak,
                selectedMonth: normalizedMonth,
                qualifyingDays: qualifyingDays,
                monthlyConsistencyRate: consistencyRate,
                underBudgetStatus: underBudgetStatus,
                failureOption: none(),
              ),
            );
          },
        );
      },
    );
  }

  /// Moves the calendar to the previous month.
  Future<void> previousMonth() async {
    final current = state.displayMonth;
    final prev = DateTime(current.year, current.month - 1);
    await load(month: prev);
  }

  /// Moves the calendar to the next month.
  Future<void> nextMonth() async {
    final current = state.displayMonth;
    final next = DateTime(current.year, current.month + 1);
    await load(month: next);
  }

  double _calculateMonthlyConsistency({
    required DateTime targetMonth,
    required Set<DateTime> qualifyingDays,
    required DateTime now,
  }) {
    final isCurrentMonth =
        targetMonth.year == now.year && targetMonth.month == now.month;

    if (isCurrentMonth) {
      final elapsedDays = now.day;
      if (elapsedDays <= 0) return 0;
      final count = qualifyingDays
          .where(
            (d) =>
                d.year == targetMonth.year &&
                d.month == targetMonth.month &&
                d.day <= now.day,
          )
          .length;
      return (count / elapsedDays).clamp(0, 1);
    }

    final targetMonthStart = DateTime(targetMonth.year, targetMonth.month);
    final currentMonthStart = DateTime(now.year, now.month);

    if (targetMonthStart.isBefore(currentMonthStart)) {
      final totalDays =
          DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
      if (totalDays <= 0) return 0;
      final count = qualifyingDays
          .where(
            (d) =>
                d.year == targetMonth.year &&
                d.month == targetMonth.month,
          )
          .length;
      return (count / totalDays).clamp(0, 1);
    }

    return 0;
  }
}
