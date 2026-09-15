import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';

/// Aggregated insights for one timeframe: totals, period-over-period
/// deltas, and the nested pillar/envelope distribution.
class InsightsSummary extends Equatable {
  const InsightsSummary({
    required this.totalOutflow,
    required this.totalInflow,
    required this.outflowDelta,
    required this.inflowDelta,
    required this.pillars,
  });

  /// Sum of expense-transaction amounts in the current window.
  final double totalOutflow;

  /// Sum of income + investment transaction amounts in the window.
  final double totalInflow;

  /// Pillars ordered by outflow descending, then inflow, then name.
  final List<PillarInsight> pillars;

  final InsightsDelta outflowDelta;
  final InsightsDelta inflowDelta;

  @override
  List<Object?> get props => [
        totalOutflow,
        totalInflow,
        outflowDelta,
        inflowDelta,
        pillars,
      ];
}

/// Period-over-period change for one flow direction.
class InsightsDelta extends Equatable {
  const InsightsDelta({
    required this.current,
    required this.previous,
    required this.isNew,
    this.changePercent,
  });

  /// Computes the delta from the two window totals.
  factory InsightsDelta.calculate({
    required double current,
    required double previous,
  }) {
    final isNew = previous == 0 && current > 0;
    final changePercent =
        previous == 0 ? null : (current - previous) / previous * 100;
    return InsightsDelta(
      current: current,
      previous: previous,
      isNew: isNew,
      changePercent: changePercent,
    );
  }

  final double current;
  final double previous;

  /// Percentage change vs the previous window; null when the previous
  /// window is zero (a percentage would be meaningless).
  final double? changePercent;

  /// True when there was no activity in the previous window but there is
  /// activity now — rendered as "new" instead of a percentage.
  final bool isNew;

  @override
  List<Object?> get props => [current, previous, changePercent, isNew];
}

/// A Level-1 pillar with its rolled-up activity for the window.
///
/// Expense-type pillars carry [outflow]; income-type pillars carry
/// [inflow]; the other side stays zero.
class PillarInsight extends Equatable {
  const PillarInsight({
    required this.pillar,
    required this.outflow,
    required this.inflow,
    required this.shareOfTotalOutflow,
    required this.envelopes,
  });

  final Category pillar;
  final double outflow;
  final double inflow;

  /// [outflow] as a fraction of the summary's total outflow (0 when the
  /// total is zero or the pillar is income-side).
  final double shareOfTotalOutflow;

  /// Direct-category buckets under this pillar, ordered by outflow
  /// descending, then inflow, then name.
  final List<EnvelopeInsight> envelopes;

  @override
  List<Object?> get props => [
        pillar,
        outflow,
        inflow,
        shareOfTotalOutflow,
        envelopes,
      ];
}

/// One direct-category bucket within a pillar.
class EnvelopeInsight extends Equatable {
  const EnvelopeInsight({
    required this.category,
    required this.breadcrumb,
    required this.outflow,
    required this.inflow,
    required this.transactionCount,
    required this.shareOfPillar,
  });

  final Category category;

  /// Full hierarchy path of [category]
  /// (e.g. "Essential › Groceries & Household › Groceries").
  final String breadcrumb;
  final double outflow;
  final double inflow;
  final int transactionCount;

  /// This envelope's activity relative to its pillar's total activity;
  /// 0 when the pillar has no activity.
  final double shareOfPillar;

  @override
  List<Object?> get props => [
        category,
        breadcrumb,
        outflow,
        inflow,
        transactionCount,
        shareOfPillar,
      ];
}
