import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Multi-segment progress bar showing each expense pillar's share of
/// total outflow, with a legend underneath. Income pillars don't take
/// bar segments (outflow-only distribution); their inflow lives in the
/// hero card and the drill-down list.
class PillarDistributionChart extends StatelessWidget {
  const PillarDistributionChart({required this.summary, super.key});

  final InsightsSummary summary;

  // Segment colours rotating per pillar, matching the
  // PortfolioDistributionCard distribution bar.
  static const _segmentColors = [
    Color(0xFF88D982), // Essential  — secondary-fixed-dim
    Color(0xFFB3C5FF), // Lifestyle  — primary-fixed-dim
    Color(0xFFFF524C), // Growth     — on-tertiary-container
  ];

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final expensePillars =
        summary.pillars.where((pillar) => pillar.outflow > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where Your Money Went',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00113A),
            ),
          ),
          const SizedBox(height: 16),
          _buildBar(expensePillars),
          const SizedBox(height: 16),
          _buildLegend(expensePillars),
        ],
      ),
    );
  }

  Widget _buildBar(List<PillarInsight> expensePillars) {
    if (expensePillars.isEmpty) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEEF),
          borderRadius: BorderRadius.circular(100),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            for (var i = 0; i < expensePillars.length; i++)
              Expanded(
                key: ValueKey('pillar_segment_$i'),
                flex: _permille(expensePillars[i]),
                child: ColoredBox(color: _segmentColor(i)),
              ),
          ],
        ),
      ),
    );
  }

  int _permille(PillarInsight pillar) {
    final share = pillar.shareOfTotalOutflow.clamp(0.0, 1.0);
    return (share * 1000).round().clamp(1, 1000);
  }

  Widget _buildLegend(List<PillarInsight> expensePillars) {
    return Column(
      children: [
        for (var i = 0; i < expensePillars.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _segmentColor(i),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    expensePillars[i].pillar.name.getOrCrash(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                ),
                Text(
                  _shareLabel(expensePillars[i].shareOfTotalOutflow),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF757682),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatAmount(expensePillars[i].outflow),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00113A),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _shareLabel(double share) => '${(share * 100).round()}%';

  Color _segmentColor(int index) {
    switch (index % _segmentColors.length) {
      case 0:
        return _segmentColors[0];
      case 1:
        return _segmentColors[1];
      default:
        return _segmentColors[2];
    }
  }
}
