import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hero streak counter section showing the flame, run length, and habit status.
class StreakHero extends StatelessWidget {
  const StreakHero({
    required this.streak,
    super.key,
    this.onLongPress,
  });

  final Streak streak;
  final VoidCallback? onLongPress;

  static const _brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00113A), Color(0xFF002366)],
  );

  static const _flameColor = Color(0xFFA0F399);
  static const _subtitleColor = Color(0xFF758DD5);

  String get _headline {
    if (streak.length == 0) {
      if (streak.status == StreakStatus.warmingUp) {
        return 'Warming Up';
      }
      return 'No Active Streak';
    }
    if (streak.length == 1) {
      return '1 Day Streak';
    }
    return '${streak.length} Day Streak';
  }

  String get _subtitle {
    switch (streak.status) {
      case StreakStatus.atRisk:
        if (streak.type == StreakType.noSpend) {
          return 'AT RISK • AVOID EXPENSES TODAY';
        }
        if (streak.type == StreakType.appOpen) {
          return 'AT RISK • OPEN APP TODAY';
        }
        return 'AT RISK • LOG AN EXPENSE TODAY';
      case StreakStatus.warmingUp:
        return 'WARMING UP • HABIT IN FORMATION';
      case StreakStatus.broken:
        if (streak.type == StreakType.noSpend) {
          return 'STREAK PAUSED • NO-SPEND DAY TO RESUME';
        }
        if (streak.type == StreakType.appOpen) {
          return 'STREAK PAUSED • OPEN DAILY TO RESUME';
        }
        return 'STREAK PAUSED • LOG TODAY TO RESUME';
      case StreakStatus.none:
        return 'START YOUR RUN TODAY';
      case StreakStatus.active:
        return 'MASTERING FINANCIAL DISCIPLINE';
    }
  }

  int get _filledDots {
    if (streak.nextMilestone <= 0 || streak.length <= 0) return 0;
    final progress = (streak.length / streak.nextMilestone).clamp(0.0, 1.0);
    return (progress * 5).round().clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$_headline, $_subtitle',
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _brandGradient,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00113A).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: _flameColor,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                _headline,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _subtitleColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isFilled = index < _filledDots;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? _flameColor
                          : _flameColor.withValues(alpha: 0.25),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
