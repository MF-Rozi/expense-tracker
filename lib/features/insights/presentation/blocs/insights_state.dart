part of 'insights_cubit.dart';

enum InsightsStatus { initial, loading, loaded, failure }

class InsightsState extends Equatable {
  const InsightsState({
    this.status = InsightsStatus.initial,
    this.selectedTimeframe = InsightsTimeframe.thisMonth,
    this.summary,
    this.failureOption = const None(),
  });

  final InsightsStatus status;
  final InsightsTimeframe selectedTimeframe;
  final InsightsSummary? summary;
  final Option<Failure> failureOption;

  InsightsState copyWith({
    InsightsStatus? status,
    InsightsTimeframe? selectedTimeframe,
    InsightsSummary? summary,
    bool clearSummary = false,
    Option<Failure>? failureOption,
  }) {
    return InsightsState(
      status: status ?? this.status,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      summary: clearSummary ? null : (summary ?? this.summary),
      failureOption: failureOption ?? this.failureOption,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTimeframe,
        summary,
        failureOption,
      ];
}
