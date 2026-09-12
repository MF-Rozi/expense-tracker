import 'package:equatable/equatable.dart';

/// The selectable analysis windows on the Insights screen.
enum InsightsTimeframe {
  thisMonth,
  lastQuarter,
  ytd;

  /// Resolves this timeframe against [now] into the current analysis
  /// range and the previous comparable range used for period-over-period
  /// deltas. All ranges are inclusive on both ends.
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

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

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
