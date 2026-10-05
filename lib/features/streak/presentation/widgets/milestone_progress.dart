import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/services/streak_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Section rendering upcoming milestone cards and progress bars.
class MilestoneProgress extends StatelessWidget {
  const MilestoneProgress({
    required this.streak,
    super.key,
  });

  final Streak streak;

  static const _ladder = StreakEngine.milestoneLadder;

  List<int> get _upcomingMilestones {
    final remaining = _ladder.where((m) => m > streak.length).toList();
    if (remaining.isEmpty) {
      final nextYear = ((streak.length ~/ 365) + 1) * 365;
      return [nextYear];
    }
    return remaining.take(2).toList();
  }

  String _titleForMilestone(int milestone) {
    switch (milestone) {
      case 7:
        return '7 Day Habit';
      case 14:
        return '14 Day Discipline';
      case 21:
        return '21 Day Routine';
      case 30:
        return 'Monthly Master';
      case 60:
        return '60 Day Dedication';
      case 90:
        return 'Quarterly Excellence';
      case 180:
        return 'Half-Year Legend';
      case 365:
        return 'Annual Champion';
      default:
        return '$milestone Day Milestone';
    }
  }

  IconData _iconForMilestone(int milestone) {
    switch (milestone) {
      case 7:
        return Icons.local_fire_department_rounded;
      case 14:
        return Icons.trending_up_rounded;
      case 21:
        return Icons.star_rounded;
      case 30:
        return Icons.savings_rounded;
      case 60:
        return Icons.workspace_premium_rounded;
      case 90:
        return Icons.military_tech_rounded;
      case 180:
        return Icons.emoji_events_rounded;
      case 365:
        return Icons.diamond_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestones = _upcomingMilestones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Upcoming Milestones',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00113A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...milestones.map((milestone) {
          final daysLeft = milestone - streak.length;
          final previousMilestone = _previousMilestone(milestone);
          final span = milestone - previousMilestone;
          final progress = span > 0
              ? ((streak.length - previousMilestone) / span).clamp(0.0, 1.0)
              : (streak.length / milestone).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MilestoneCard(
              title: _titleForMilestone(milestone),
              daysLeft: daysLeft,
              icon: _iconForMilestone(milestone),
              progress: progress,
            ),
          );
        }),
      ],
    );
  }

  int _previousMilestone(int milestone) {
    final index = _ladder.indexOf(milestone);
    if (index > 0) {
      return _ladder[index - 1];
    }
    return 0;
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.title,
    required this.daysLeft,
    required this.icon,
    required this.progress,
  });

  final String title;
  final int daysLeft;
  final IconData icon;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final daysLeftLabel = daysLeft == 1 ? '1 day left' : '$daysLeft days left';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00113A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00113A),
                      ),
                    ),
                    Text(
                      daysLeftLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF757682),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00113A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
