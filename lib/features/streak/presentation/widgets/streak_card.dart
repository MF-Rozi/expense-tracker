import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_config_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact flame card displayed on the home dashboard.
///
/// Tap navigates to `/streaks`; long-press opens the [StreakConfigSheet].
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
    return '$prefix${streak.length} Day Streak';
  }

  String get _subtitle {
    if (streak.status == StreakStatus.atRisk) {
      switch (streak.type) {
        case StreakType.noSpend:
          return 'At risk! Avoid expenses today to keep your streak';
        case StreakType.appOpen:
          return 'At risk! Open app today to keep your streak';
        case StreakType.tracking:
        case StreakType.underBudget:
          return 'At risk! Log today to keep your streak';
      }
    }
    if (streak.status == StreakStatus.warmingUp) {
      return 'Warming up · Keep logging to activate your streak';
    }
    final remaining = streak.nextMilestone - streak.length;
    final dayWord = remaining == 1 ? 'day' : 'days';
    return '$remaining $dayWord to next milestone';
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
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ??
              () => context.push(
                    '/streaks?type=${streak.type.name}',
                  ),
          onLongPress: onLongPress ??
              () => StreakConfigSheet.show(
                    context,
                    initialType: streak.type,
                  ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
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
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isAtRisk
                                  ? const Color(0xFFBA1A1A)
                                  : const Color(0xFF444650),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF757682),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: _progressFraction,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F2F6),
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
