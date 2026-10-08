/// Defines the streak types supported across all streak phases.
enum StreakType {
  /// Tracking streak: qualifies when at least one transaction is recorded.
  tracking,

  /// No-spend streak: qualifies when no expenses are recorded on that day.
  noSpend,

  /// App-open consistency streak: qualifies when the user opens the app
  /// within cadence.
  appOpen,

  /// Under-budget streak: monthly discipline streak when expenses are within
  /// budget.
  underBudget;

  /// Active streak types available in Phase 2.
  static const activeTypes = [
    StreakType.tracking,
    StreakType.noSpend,
    StreakType.appOpen,
  ];

  /// Short display label for chips and tabs.
  String get shortLabel {
    switch (this) {
      case StreakType.tracking:
        return 'Tracking';
      case StreakType.noSpend:
        return 'No-Spend';
      case StreakType.appOpen:
        return 'App Open';
      case StreakType.underBudget:
        return 'Budget';
    }
  }

  String get displayName {
    switch (this) {
      case StreakType.tracking:
        return 'Tracking Streak';
      case StreakType.noSpend:
        return 'No-Spend Streak';
      case StreakType.appOpen:
        return 'App-Open Streak';
      case StreakType.underBudget:
        return 'Under-Budget Streak';
    }
  }
}
