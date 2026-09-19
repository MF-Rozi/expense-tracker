import 'package:equatable/equatable.dart';

/// The selectable analysis windows on the Insights screen.
enum InsightsTimeframe {
  thisMonth,
  lastQuarter,
  ytd,
  allTime,
  custom;

  /// Resolves this timeframe against [now] into the current analysis
  /// range and the previous comparable range used for period-over-period
  /// deltas. All ranges are inclusive on both ends.
  ///
  /// [allTime] and [custom] have no derived window: all time is fetched
  /// unfiltered, and a custom range is supplied by the caller — see
  /// `GetInsightsSummaryParams.customRange` and the equal-length
  /// previous-window rule in the usecase.
  InsightsWindow resolve(DateTime now) {
    switch (this) {
      case InsightsTimeframe.thisMonth:
        final start = DateTime(now.year, now.month);
        final end = _endOf(DateTime(now.year, now.month + 1));
        final previousStart = DateTime(now.year, now.month - 1);
        final previousEnd = _endOf(DateTime(now.year, now.month));
        return InsightsWindow(
          current: DateRange(start: start, end: end),
          previous: DateRange(start: previousStart, end: previousEnd),
        );
      case InsightsTimeframe.lastQuarter:
        // Zero-based quarter index for the CURRENT quarter; "last
        // quarter" is the calendar quarter before it.
        final quarterIndex = (now.month - 1) ~/ 3;
        final lastQuarterStartMonth = quarterIndex * 3 - 2;
        final start = DateTime(now.year, lastQuarterStartMonth);
        final end = _endOf(DateTime(now.year, lastQuarterStartMonth + 3));
        final previousStart = DateTime(now.year, lastQuarterStartMonth - 3);
        final previousEnd = _endOf(DateTime(now.year, lastQuarterStartMonth));
        return InsightsWindow(
          current: DateRange(start: start, end: end),
          previous: DateRange(start: previousStart, end: previousEnd),
        );
      case InsightsTimeframe.ytd:
        final start = DateTime(now.year);
        final end = DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
          999,
        );
        final previousStart = DateTime(now.year - 1);
        final previousEnd = DateTime(
          now.year - 1,
          now.month,
          now.day,
          23,
          59,
          59,
          999,
        );
        return InsightsWindow(
          current: DateRange(start: start, end: end),
          previous: DateRange(start: previousStart, end: previousEnd),
        );
      case InsightsTimeframe.allTime:
      case InsightsTimeframe.custom:
        throw UnsupportedError(
          '$name has no derived window — the usecase handles it directly',
        );
    }
  }

  /// Last millisecond of the day before the first instant of [firstOfNext].
  static DateTime _endOf(DateTime firstOfNext) =>
      firstOfNext.subtract(const Duration(milliseconds: 1));
}

/// A half-open-in-name-only inclusive range [start, end].
class DateRange extends Equatable {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// Number of days covered, counting both end days (never zero).
  /// Callers should pass midnight-normalized boundaries so the count is
  /// exact.
  int get daySpan => end.difference(start).inDays + 1;

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

  /// The equal-length window immediately before this one — the
  /// period-over-period comparison for custom ranges.
  DateRange previousEqualLength() {
    final previousEnd = start.subtract(const Duration(milliseconds: 1));
    final previousStart = DateTime(
      previousEnd.year,
      previousEnd.month,
      previousEnd.day,
    ).subtract(Duration(days: daySpan - 1));
    return DateRange(start: previousStart, end: previousEnd);
  }

  @override
  List<Object?> get props => [start, end];
}

/// The current and previous comparable ranges for a timeframe.
class InsightsWindow extends Equatable {
  const InsightsWindow({required this.current, required this.previous});

  final DateRange current;
  final DateRange previous;

  @override
  List<Object?> get props => [current, previous];
}
