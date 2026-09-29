/// The lifecycle status of a streak run.
enum StreakStatus {
  /// No records exist or no run has started yet.
  none,

  /// Run length is below the configured minimum threshold (default 3).
  ///
  /// Per R5, celebration is withheld and UI frames this as warming up.
  warmingUp,

  /// Run length is at or above the minimum and the run is healthy.
  active,

  /// Run length is at or above the minimum, today is unqualified,
  /// and today is the last day covered by the window (window closes tomorrow).
  atRisk,

  /// The gap between the last qualifying period and the evaluation date
  /// exceeded the window, terminating the run.
  broken;

  bool get isNone => this == StreakStatus.none;
  bool get isWarmingUp => this == StreakStatus.warmingUp;
  bool get isActive => this == StreakStatus.active;
  bool get isAtRisk => this == StreakStatus.atRisk;
  bool get isBroken => this == StreakStatus.broken;

  /// Whether the streak is in a celebratory state (active or at risk).
  ///
  /// Below the minimum threshold, the UI frames as warming up (R5).
  bool get isCelebratory =>
      this == StreakStatus.active || this == StreakStatus.atRisk;
}
