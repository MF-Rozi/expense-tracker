import 'package:equatable/equatable.dart';

/// Configuration parameters for streak evaluation.
class StreakConfig extends Equatable {
  const StreakConfig({
    this.window = defaultWindow,
    this.minimum = defaultMinimum,
    this.cadence = defaultCadence,
  })  : assert(window >= 1, 'Window must be at least 1'),
        assert(minimum >= 1, 'Minimum must be at least 1'),
        assert(cadence >= 1, 'Cadence must be at least 1');

  /// Default window in days (3 days).
  static const int defaultWindow = 3;

  /// Default minimum days to celebrate an active streak (3 days).
  static const int defaultMinimum = 3;

  /// Default app-open cadence in days (7 days).
  static const int defaultCadence = 7;

  /// The maximum gap allowed between consecutive qualifying periods
  /// without breaking the run.
  final int window;

  /// The minimum span of periods required to celebrate the streak as active.
  final int minimum;

  /// The cadence used for app-open consistency streaks.
  final int cadence;

  StreakConfig copyWith({
    int? window,
    int? minimum,
    int? cadence,
  }) {
    return StreakConfig(
      window: window ?? this.window,
      minimum: minimum ?? this.minimum,
      cadence: cadence ?? this.cadence,
    );
  }

  @override
  List<Object?> get props => [window, minimum, cadence];
}
