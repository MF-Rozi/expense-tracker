part of 'insights_cubit.dart';

enum InsightsStatus { initial, loading, loaded, failure }

class InsightsState extends Equatable {
  const InsightsState({
    this.status = InsightsStatus.initial,
    this.selectedTimeframe = InsightsTimeframe.thisMonth,
    this.customRange,
    this.summary,
    this.failureOption = const None(),
  });

  final InsightsStatus status;
  final InsightsTimeframe selectedTimeframe;

  /// Set when the user picks a custom range; reset when a preset
  /// timeframe is selected.
  final DateRange? customRange;
  final InsightsSummary? summary;
  final Option<Failure> failureOption;

  InsightsState copyWith({
    InsightsStatus? status,
    InsightsTimeframe? selectedTimeframe,
    DateRange? customRange,
    bool clearCustomRange = false,
    InsightsSummary? summary,
    bool clearSummary = false,
    Option<Failure>? failureOption,
  }) {
    return InsightsState(
      status: status ?? this.status,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      customRange: clearCustomRange ? null : (customRange ?? this.customRange),
      summary: clearSummary ? null : (summary ?? this.summary),
      failureOption: failureOption ?? this.failureOption,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTimeframe,
        customRange,
        summary,
        failureOption,
      ];
}
