import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:expense_tracker/features/insights/domain/usecases/get_insights_summary_usecase.dart';
import 'package:injectable/injectable.dart';

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
    InsightsNowProvider? nowProvider,
  })  : _nowProvider = nowProvider ?? DateTime.now,
        super(const InsightsState());

  final GetInsightsSummaryUseCase _loadInsightsSummary;
  final InsightsNowProvider _nowProvider;

  int _requestToken = 0;

  /// Fetches the currently selected timeframe.
  Future<void> load() => _fetch(state.selectedTimeframe);

  /// Switches the timeframe and fetches it.
  Future<void> selectTimeframe(InsightsTimeframe timeframe) {
    if (timeframe != state.selectedTimeframe) {
      emit(state.copyWith(selectedTimeframe: timeframe));
    }
    return _fetch(timeframe);
  }

  /// Re-fetches the current timeframe (pull-to-refresh).
  Future<void> refresh() => _fetch(state.selectedTimeframe);

  Future<void> _fetch(InsightsTimeframe timeframe) async {
    final token = ++_requestToken;
    emit(
      state.copyWith(
        status: InsightsStatus.loading,
        failureOption: const None(),
      ),
    );

    final result = await _loadInsightsSummary(
      GetInsightsSummaryParams(timeframe: timeframe, now: _nowProvider()),
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
