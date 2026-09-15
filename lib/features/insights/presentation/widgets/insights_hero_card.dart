import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Gradient hero showing total outflow/inflow with period-over-period
/// delta chips.
class InsightsHeroCard extends StatelessWidget {
  const InsightsHeroCard({required this.summary, super.key});

  final InsightsSummary summary;

  static const _gradientStart = Color(0xFF00113A);
  static const _gradientEnd = Color(0xFF002366);
  static const _green = Color(0xFF3CD150);
  static const _red = Color(0xFFFF6B6B);

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientStart, _gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _gradientStart.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL OUTFLOW',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatAmount(summary.totalOutflow),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              _DeltaChip(delta: summary.outflowDelta, isOutflow: true),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          _buildFlowRow(
            icon: Icons.south_west,
            label: 'INFLOW',
            amount: summary.totalInflow,
            delta: summary.inflowDelta,
            isOutflow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRow({
    required IconData icon,
    required String label,
    required double amount,
    required InsightsDelta delta,
    required bool isOutflow,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatAmount(amount),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _DeltaChip(delta: delta, isOutflow: isOutflow),
      ],
    );
  }
}

/// Direction-aware delta chip: an outflow increase is bad (red), an
/// inflow increase is good (green). Zero previous activity shows a
/// neutral "NEW" chip; a completely silent period shows a dash.
class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta, required this.isOutflow});

  final InsightsDelta delta;
  final bool isOutflow;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;

    if (delta.isNew) {
      bgColor = Colors.white.withValues(alpha: 0.12);
      fgColor = Colors.white.withValues(alpha: 0.85);
      return _chip(bgColor, fgColor, 'NEW');
    }

    final changePercent = delta.changePercent;
    if (changePercent == null) {
      bgColor = Colors.white.withValues(alpha: 0.12);
      fgColor = Colors.white.withValues(alpha: 0.5);
      return _chip(bgColor, fgColor, '—');
    }

    final increased = changePercent > 0;
    final isGood = isOutflow ? !increased : increased;
    bgColor = (isGood ? InsightsHeroCard._green : InsightsHeroCard._red)
        .withValues(alpha: 0.18);
    fgColor = isGood ? InsightsHeroCard._green : InsightsHeroCard._red;

    final arrow = increased ? '▲' : '▼';
    return _chip(bgColor, fgColor, '$arrow ${changePercent.round().abs()}%');
  }

  Widget _chip(Color background, Color foreground, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
