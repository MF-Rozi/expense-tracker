import 'package:equatable/equatable.dart';

/// Progress snapshot of the hidden Counter Easter egg.
///
/// The ritual: tap the version row in Settings [versionTapsRequired]
/// times to reveal the hint, then complete the three listed steps.
class EasterEggProgress extends Equatable {
  const EasterEggProgress({
    this.versionTaps = 0,
    this.hintSeen = false,
    this.loggedTransaction = false,
    this.visitedStats = false,
    this.openedCategories = false,
    this.unlocked = false,
  });

  static const int versionTapsRequired = 7;
  static const int totalSteps = 3;

  final int versionTaps;
  final bool hintSeen;
  final bool loggedTransaction;
  final bool visitedStats;
  final bool openedCategories;
  final bool unlocked;

  int get completedSteps => [
        loggedTransaction,
        visitedStats,
        openedCategories,
      ].where((step) => step).length;

  EasterEggProgress copyWith({
    int? versionTaps,
    bool? hintSeen,
    bool? loggedTransaction,
    bool? visitedStats,
    bool? openedCategories,
    bool? unlocked,
  }) {
    return EasterEggProgress(
      versionTaps: versionTaps ?? this.versionTaps,
      hintSeen: hintSeen ?? this.hintSeen,
      loggedTransaction: loggedTransaction ?? this.loggedTransaction,
      visitedStats: visitedStats ?? this.visitedStats,
      openedCategories: openedCategories ?? this.openedCategories,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  @override
  List<Object?> get props => [
        versionTaps,
        hintSeen,
        loggedTransaction,
        visitedStats,
        openedCategories,
        unlocked,
      ];
}
