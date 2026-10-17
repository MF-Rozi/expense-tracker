import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact flame badge displayed in headers and app bars.
///
/// Tapping navigates to `/streaks?type=${streak.type.name}`.
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.streak,
    this.onTap,
    super.key,
  });

  final Streak streak;
  final VoidCallback? onTap;

  Color get _backgroundColor {
    if (streak.isEmpty || streak.status == StreakStatus.none) {
      return const Color(0xFFF3F4F6);
    }
    if (streak.status == StreakStatus.atRisk) {
      return const Color(0xFFFEF3C7);
    }
    if (streak.status == StreakStatus.warmingUp) {
      return const Color(0xFFFFFBEB);
    }
    return const Color(0xFFFFEDD5);
  }

  Color get _borderColor {
    if (streak.isEmpty || streak.status == StreakStatus.none) {
      return const Color(0xFFE5E7EB);
    }
    if (streak.status == StreakStatus.atRisk) {
      return const Color(0xFFF59E0B).withValues(alpha: 0.4);
    }
    return const Color(0xFFF97316).withValues(alpha: 0.3);
  }

  Color get _flameColor {
    if (streak.isEmpty || streak.status == StreakStatus.none) {
      return const Color(0xFF9CA3AF);
    }
    if (streak.status == StreakStatus.atRisk) {
      return const Color(0xFFD97706);
    }
    return const Color(0xFFEA580C);
  }

  Color get _textColor {
    if (streak.isEmpty || streak.status == StreakStatus.none) {
      return const Color(0xFF6B7280);
    }
    if (streak.status == StreakStatus.atRisk) {
      return const Color(0xFF92400E);
    }
    return const Color(0xFF9A3412);
  }

  @override
  Widget build(BuildContext context) {
    final count = streak.length;

    return Semantics(
      button: true,
      label: '$count day streak',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ??
              () {
                context.push('/streaks?type=${streak.type.name}');
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: _flameColor,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
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
