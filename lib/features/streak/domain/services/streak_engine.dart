import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:injectable/injectable.dart';

/// Calculation result containing both the current streak run and the best
/// historical run.
class StreakEngineResult extends Equatable {
  const StreakEngineResult({
    required this.current,
    required this.best,
  });

  final Streak current;
  final Streak best;

  @override
  List<Object?> get props => [current, best];
}

/// Pure domain service calculating streak metrics over an ordered sequence of
/// [StreakPeriod]s.
///
/// Period-abstract from day one: works identically for daily and monthly
/// periods.
/// Completely free of Flutter and I/O dependencies.
@lazySingleton
class StreakEngine {
  const StreakEngine();

  /// Shared milestone progression ladder per Key Technical Decisions.
  static const List<int> milestoneLadder = [7, 14, 21, 30, 60, 90, 180, 365];

  /// Resolves the next milestone threshold strictly greater than [length].
  static int resolveNextMilestone(int length) {
    for (final milestone in milestoneLadder) {
      if (milestone > length) {
        return milestone;
      }
    }
    // For values >= 365, return the next full-year threshold.
    final years = (length ~/ 365) + 1;
    return years * 365;
  }

  /// Calculates the current and best streak runs.
  ///
  /// - [qualifyingPeriods]: Periods that qualify for this streak.
  /// - [today]: The reference evaluation period (e.g. today's date).
  /// - [config]: Tuning parameters (window, minimum).
  /// - [type]: The streak category being computed.
  StreakEngineResult calculate({
    required Iterable<StreakPeriod> qualifyingPeriods,
    required StreakPeriod today,
    required StreakConfig config,
    StreakType type = StreakType.tracking,
  }) {
    // 1. Filter out future dates, deduplicate, and sort ascending.
    final validPeriods = qualifyingPeriods
        .where((p) => p.compareTo(today) <= 0)
        .toSet()
        .toList()
      ..sort();

    // 2. Consistency rate calculation: qualifying in container / elapsed.
    final qualifyingInContainer = validPeriods
        .where((p) => today.isInSameContainer(p) && p.compareTo(today) <= 0)
        .length;
    final elapsed = today.elapsedInContainer;
    final consistencyRate =
        elapsed > 0 ? (qualifyingInContainer / elapsed) : 0.0;

    // 3. Handle empty records.
    if (validPeriods.isEmpty) {
      final emptyStreak = Streak.empty(type: type).copyWith(
        consistencyRate: consistencyRate,
      );
      return StreakEngineResult(current: emptyStreak, best: emptyStreak);
    }

    // 4. Partition periods into contiguous runs separated by gaps <= window.
    final runs = <List<StreakPeriod>>[];
    var currentRun = <StreakPeriod>[validPeriods.first];

    for (var i = 1; i < validPeriods.length; i++) {
      final prev = validPeriods[i - 1];
      final curr = validPeriods[i];
      final diff = curr.differenceInPeriods(prev);

      if (diff <= config.window) {
        currentRun.add(curr);
      } else {
        runs.add(currentRun);
        currentRun = [curr];
      }
    }
    runs.add(currentRun);

    // 5. Determine the best historical run.
    var maxRunLength = 0;
    var bestRun = runs.first;

    for (final run in runs) {
      final runLength = run.last.differenceInPeriods(run.first) + 1;
      if (runLength >= maxRunLength) {
        maxRunLength = runLength;
        bestRun = run;
      }
    }

    // 6. Evaluate the current run (the last run in the sequence).
    final lastRun = runs.last;
    final pLast = lastRun.last;
    final pFirst = lastRun.first;
    final delta = today.differenceInPeriods(pLast);

    final Streak currentStreak;

    if (delta > config.window) {
      // The gap between the latest qualifying period and today exceeds window.
      // The previous run has ended; there is no active run today.
      currentStreak = Streak(
        type: type,
        length: 0,
        status: StreakStatus.broken,
        daysUntilBreak: 0,
        nextMilestone: resolveNextMilestone(0),
        consistencyRate: consistencyRate,
        bestLength: maxRunLength,
      );
    } else {
      // The run is still active or alive within the grace window.
      final currentLength = pLast.differenceInPeriods(pFirst) + 1;
      final isTodayQualified = delta == 0;

      final int daysUntilBreak;
      if (isTodayQualified) {
        daysUntilBreak = config.window;
      } else {
        daysUntilBreak = config.window - delta + 1;
      }

      final StreakStatus status;
      if (currentLength < config.minimum) {
        status = StreakStatus.warmingUp;
      } else {
        if (!isTodayQualified && delta == config.window) {
          status = StreakStatus.atRisk;
        } else {
          status = StreakStatus.active;
        }
      }

      currentStreak = Streak(
        type: type,
        length: currentLength,
        status: status,
        daysUntilBreak: daysUntilBreak,
        nextMilestone: resolveNextMilestone(currentLength),
        consistencyRate: consistencyRate,
        bestLength:
            maxRunLength > currentLength ? maxRunLength : currentLength,
      );
    }

    final bestRunLength = bestRun.last.differenceInPeriods(bestRun.first) + 1;
    final bestStreak = Streak(
      type: type,
      length: bestRunLength,
      status: bestRunLength >= config.minimum
          ? StreakStatus.active
          : (bestRunLength > 0 ? StreakStatus.warmingUp : StreakStatus.none),
      daysUntilBreak: 0,
      nextMilestone: resolveNextMilestone(bestRunLength),
      consistencyRate: consistencyRate,
      bestLength: bestRunLength,
    );

    return StreakEngineResult(current: currentStreak, best: bestStreak);
  }
}
