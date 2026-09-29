import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';

/// Represents a derived streak state for a given [StreakType].
class Streak extends Equatable {
  const Streak({
    required this.type,
    required this.length,
    required this.status,
    required this.daysUntilBreak,
    required this.nextMilestone,
    required this.consistencyRate,
    this.bestLength = 0,
  });

  /// Factory constructor for an empty streak when no records exist.
  const Streak.empty({
    this.type = StreakType.tracking,
  })  : length = 0,
        status = StreakStatus.none,
        daysUntilBreak = 0,
        nextMilestone = 7,
        consistencyRate = 0.0,
        bestLength = 0;

  /// The streak category.
  final StreakType type;

  /// Length of the current run counting inclusive calendar periods.
  final int length;

  /// Current status: none, warmingUp, active, atRisk, or broken.
  final StreakStatus status;

  /// Number of days remaining before the current run breaks unless extended.
  final int daysUntilBreak;

  /// The upcoming milestone threshold (e.g. 7, 14, 21, 30, ...).
  final int nextMilestone;

  /// Consistency rate for the current period container (0.0 to 1.0).
  final double consistencyRate;

  /// The longest historical streak length for this type.
  final int bestLength;

  /// Whether this streak has no activity.
  bool get isEmpty => length == 0 && status == StreakStatus.none;

  Streak copyWith({
    StreakType? type,
    int? length,
    StreakStatus? status,
    int? daysUntilBreak,
    int? nextMilestone,
    double? consistencyRate,
    int? bestLength,
  }) {
    return Streak(
      type: type ?? this.type,
      length: length ?? this.length,
      status: status ?? this.status,
      daysUntilBreak: daysUntilBreak ?? this.daysUntilBreak,
      nextMilestone: nextMilestone ?? this.nextMilestone,
      consistencyRate: consistencyRate ?? this.consistencyRate,
      bestLength: bestLength ?? this.bestLength,
    );
  }

  @override
  List<Object?> get props => [
        type,
        length,
        status,
        daysUntilBreak,
        nextMilestone,
        consistencyRate,
        bestLength,
      ];
}
