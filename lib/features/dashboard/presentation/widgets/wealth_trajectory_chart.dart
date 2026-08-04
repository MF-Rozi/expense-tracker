import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WealthTrajectoryChart extends StatelessWidget {
  const WealthTrajectoryChart({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Your net worth increased by 8.2% this month.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF757682),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(40, false),
                _buildBar(60, false),
                _buildBar(50, false),
                _buildBar(80, false),
                _buildBar(110, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isHighlighted) {
    return Container(
      width: 40,
      height: height,
      decoration: BoxDecoration(
        color:
            isHighlighted ? const Color(0xFF00113A) : const Color(0xFFE5E7EB),
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
    );
  }
}
