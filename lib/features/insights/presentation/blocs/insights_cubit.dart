import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:expense_tracker/features/insights/domain/usecases/get_insights_summary_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

part 'insights_state.dart';

/// Injectable can't resolve bare function types in constructor params.
typedef InsightsNowProvider = DateTime Function();

/// Fetches insights summaries on demand (open, timeframe switch,
/// pull-to-refresh) — never subscribes to live streams. Stale responses
/// from rapid timeframe switches are discarded; the newest request wins.
@injectable
class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit(
    this._loadInsightsSummary, {
    @ignoreParam InsightsNowProvider? nowProvider,
  })  : _nowProvider = nowProvider ?? DateTime.now,
        super(const InsightsState());

  final GetInsightsSummaryUseCase _loadInsightsSummary;
  final InsightsNowProvider _nowProvider;

  int _requestToken = 0;

  /// Fetches the currently selected timeframe.
  Future<void> load() => _fetch(state.selectedTimeframe);

  /// Switches to a preset timeframe and fetches it. Clears any custom
  /// range so refresh() keeps the preset behavior.
  Future<void> selectTimeframe(InsightsTimeframe timeframe) {
    if (timeframe == InsightsTimeframe.custom) {
      throw ArgumentError(
        'use selectCustomRange for the custom timeframe',
      );
    }
    emit(
      state.copyWith(
        selectedTimeframe: timeframe,
        clearCustomRange: true,
      ),
    );
    return _fetch(timeframe);
  }

  /// Picks a custom range, switches the timeframe to custom, and
  /// fetches. Boundaries are normalized to full days.
  Future<void> selectCustomRange(DateTime start, DateTime end) {
    final normalized = DateRange(
      start: DateTime(start.year, start.month, start.day),
      end: DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
    );
    emit(
      state.copyWith(
        selectedTimeframe: InsightsTimeframe.custom,
        customRange: normalized,
      ),
    );
    return _fetch(InsightsTimeframe.custom);
  }

  /// Re-fetches the current timeframe (pull-to-refresh).
  Future<void> refresh() => _fetch(state.selectedTimeframe);

  String _periodLabel(
    InsightsTimeframe timeframe,
    DateRange? customRange,
    DateTime now,
  ) {
    switch (timeframe) {
      case InsightsTimeframe.thisMonth:
        return DateFormat('MMMM yyyy').format(now);
      case InsightsTimeframe.lastQuarter:
        final window = timeframe.resolve(now);
        return '${DateFormat('MMM').format(window.current.start)} – '
            '${DateFormat('MMM yyyy').format(window.current.end)}';
      case InsightsTimeframe.ytd:
        return 'Jan 1 – ${DateFormat('MMM d, yyyy').format(now)}';
      case InsightsTimeframe.allTime:
        return 'All Time';
      case InsightsTimeframe.custom:
        final range = customRange;
        if (range == null) return 'Custom';
        final sameYear = range.start.year == range.end.year;
        final startFormat =
            sameYear ? DateFormat('d MMM') : DateFormat('d MMM yyyy');
        return '${startFormat.format(range.start)} – '
            '${DateFormat('d MMM yyyy').format(range.end)}';
    }
  }

  Future<void> _fetch(InsightsTimeframe timeframe) async {
    final token = ++_requestToken;
    emit(
      state.copyWith(
        status: InsightsStatus.loading,
        failureOption: const None(),
      ),
    );

    final now = _nowProvider();
    final result = await _loadInsightsSummary(
      GetInsightsSummaryParams(
        timeframe: timeframe,
        now: now,
        customRange: state.customRange,
        periodLabel: _periodLabel(timeframe, state.customRange, now),
      ),
    );

    // A newer request superseded this one — drop the stale response.
    if (token != _requestToken) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: InsightsStatus.failure,
          failureOption: Some(failure),
        ),
      ),
      (summary) => emit(
        state.copyWith(
          status: InsightsStatus.loaded,
          summary: summary,
          failureOption: const None(),
        ),
      ),
    );
  }
}
