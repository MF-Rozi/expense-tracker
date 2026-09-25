import 'package:equatable/equatable.dart';

/// A single point in the 5-month wealth trajectory timeline.
class TrajectoryPoint extends Equatable {
  const TrajectoryPoint({
    required this.month,
    required this.netWorth,
    required this.isCurrentMonth,
  });

  /// The month represented by this point (typically day 1 of the month).
  final DateTime month;

  /// Cumulative net worth (cumulative balance through the end of this month).
  final double netWorth;

  /// Whether this point represents the current active month.
  final bool isCurrentMonth;

  @override
  List<Object?> get props => [month, netWorth, isCurrentMonth];
}

/// Represents the rolling 5-month wealth trajectory and growth summary.
class WealthTrajectory extends Equatable {
  const WealthTrajectory({
    required this.points,
    required this.growthPercentage,
    required this.headlineDescription,
  });

  /// Exactly 5 monthly points ordered chronologically from M-4 to M.
  final List<TrajectoryPoint> points;

  /// Month-over-month growth percentage from M-1 to M.
  /// Null if previous month has zero net worth or base is unavailable.
  final double? growthPercentage;

  /// Contextual copy describing trajectory
  /// (e.g. "Your net worth increased by 8.2% this month.").
  final String headlineDescription;

  @override
  List<Object?> get props => [points, growthPercentage, headlineDescription];
}
