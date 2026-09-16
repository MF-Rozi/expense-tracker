import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Capsule segmented control for the analysis timeframes. Five options
/// don't fit a phone width, so the row scrolls horizontally; a Custom
/// selection opens the date-range picker from the page.
class TimeframeFilterRow extends StatelessWidget {
  const TimeframeFilterRow({
    required this.selected,
    required this.onTimeframeChanged,
    required this.onCustomSelected,
    super.key,
  });

  final InsightsTimeframe selected;
  final ValueChanged<InsightsTimeframe> onTimeframeChanged;
  final VoidCallback onCustomSelected;

  static const _trackColor = Color(0xFFF3F4F5);
  static const _inactiveColor = Color(0xFF444650);
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00113A), Color(0xFF002366)],
  );

  static const _labels = {
    InsightsTimeframe.thisMonth: 'This Month',
    InsightsTimeframe.lastQuarter: 'Last Quarter',
    InsightsTimeframe.ytd: 'YTD',
    InsightsTimeframe.allTime: 'All Time',
    InsightsTimeframe.custom: 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _trackColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final timeframe in InsightsTimeframe.values) ...[
              if (timeframe != InsightsTimeframe.thisMonth)
                const SizedBox(width: 4),
              _buildSegment(timeframe),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(InsightsTimeframe timeframe) {
    final isActive = timeframe == selected;
    final label = _labels[timeframe]!;

    return GestureDetector(
      onTap: () => timeframe == InsightsTimeframe.custom
          ? onCustomSelected()
          : onTimeframeChanged(timeframe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? _gradient : null,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: isActive
                ? GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )
                : GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _inactiveColor,
                  ),
          ),
        ),
      ),
    );
  }
}
