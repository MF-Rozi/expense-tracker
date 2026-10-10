import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact flame card displayed on the home dashboard.
///
/// Tap navigates to `/streaks`.
/// When the streak is empty, this widget renders [SizedBox.shrink].
class StreakCard extends StatelessWidget {
  const StreakCard({
    required this.streak,
    super.key,
    this.onTap,
    this.onLongPress,
  });

  final Streak streak;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  String get _title {
    final prefix = streak.type == StreakType.tracking
        ? ''
        : '${streak.type.shortLabel} · ';
    if (streak.status == StreakStatus.warmingUp) {
      return '${prefix}Warming Up';
    }
    final unit = streak.type == StreakType.underBudget ? 'Month' : 'Day';
    return '$prefix${streak.length} $unit Streak';
  }

  String get _subtitle {
    if (streak.status == StreakStatus.atRisk) {
      switch (streak.type) {
        case StreakType.noSpend:
          return 'At risk! Avoid expenses today to keep your streak';
        case StreakType.appOpen:
          return 'At risk! Open app today to keep your streak';
        case StreakType.underBudget:
          return 'At risk! Stay under budget this month to keep your streak';
        case StreakType.tracking:
          return 'At risk! Log today to keep your streak';
      }
    }
    if (streak.status == StreakStatus.warmingUp) {
      return streak.type == StreakType.underBudget
          ? 'Warming up · Stay under budget to activate your streak'
          : 'Warming up · Keep logging to activate your streak';
    }
    final remaining = streak.nextMilestone - streak.length;
    final unitWord = streak.type == StreakType.underBudget
        ? (remaining == 1 ? 'month' : 'months')
        : (remaining == 1 ? 'day' : 'days');
    return '$remaining $unitWord to next milestone';
  }

  Color get _accentColor {
    if (streak.status == StreakStatus.atRisk) {
      return const Color(0xFFBA1A1A);
    }
    if (streak.status == StreakStatus.warmingUp) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFFF97316);
  }

  Color get _flameContainerColor {
    if (streak.status == StreakStatus.atRisk) {
      return const Color(0xFFFFDAD6);
    }
    if (streak.status == StreakStatus.warmingUp) {
      return const Color(0xFFFFF3E0);
    }
    return const Color(0xFFFFEDD5);
  }

  double get _progressFraction {
    if (streak.nextMilestone <= 0) return 0;
    return (streak.length / streak.nextMilestone).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (streak.isEmpty || streak.status == StreakStatus.none) {
      return const SizedBox.shrink();
    }

    final isAtRisk = streak.status == StreakStatus.atRisk;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAtRisk
              ? const Color(0xFFFFB4AB).withValues(alpha: 0.8)
              : const Color(0xFFE5E7EB),
          width: isAtRisk ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isAtRisk
                ? const Color(0xFFBA1A1A).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ??
              () {
                context.push('/streaks?type=${streak.type.name}');
              },
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Flame icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _flameContainerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: _accentColor,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Streak text & milestone progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _title,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00113A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isAtRisk
                              ? const Color(0xFFBA1A1A)
                              : const Color(0xFF757682),
                          fontWeight: isAtRisk
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressFraction,
                          backgroundColor: const Color(0xFFF3F4F6),
                          color: _accentColor,
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Trailing chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: isAtRisk
                      ? const Color(0xFFBA1A1A)
                      : const Color(0xFF9CA3AF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
