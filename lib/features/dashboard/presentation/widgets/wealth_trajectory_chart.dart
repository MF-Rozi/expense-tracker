import 'dart:math' as math;
import 'package:expense_tracker/features/dashboard/domain/entities/wealth_trajectory.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WealthTrajectoryChart extends StatelessWidget {
  const WealthTrajectoryChart({
    super.key,
    this.trajectory,
  });

  final WealthTrajectory? trajectory;

  @override
  Widget build(BuildContext context) {
    final points = trajectory?.points ?? const [];
    final description =
        trajectory?.headlineDescription ?? 'No transaction data yet.';

    // Calculate maximum net worth to scale bars proportionally
    var maxNetWorth = 0.0;
    for (final p in points) {
      if (p.netWorth > maxNetWorth) {
        maxNetWorth = p.netWorth;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wealth Trajectory',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00113A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF757682),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                // Minimum bar height 8, maximum 100
                final double barHeight;
                if (maxNetWorth <= 0 || point.netWorth <= 0) {
                  barHeight = 8;
                } else {
                  final ratio = point.netWorth / maxNetWorth;
                  barHeight = math.max(8, ratio * 100);
                }

                final monthLabel = DateFormat('MMM').format(point.month);

                return _TrajectoryBarColumn(
                  height: barHeight,
                  label: monthLabel,
                  isHighlighted: point.isCurrentMonth,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrajectoryBarColumn extends StatelessWidget {
  const _TrajectoryBarColumn({
    required this.height,
    required this.label,
    required this.isHighlighted,
  });

  final double height;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF00113A)
                : const Color(0xFFE5E7EB),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: const Color(0xFF00113A).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: isHighlighted
                ? const Color(0xFF00113A)
                : const Color(0xFF757682),
          ),
        ),
      ],
    );
  }
}
