import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Per-pillar envelope breakdown: a header per pillar with its rolled-up
/// total, then one row per direct-category bucket with breadcrumb,
/// activity share, and amount. Pillars without activity are omitted.
class EnvelopeDrillDownList extends StatelessWidget {
  const EnvelopeDrillDownList({required this.pillars, super.key});

  final List<PillarInsight> pillars;

  static const _muted = Color(0xFF757682);
  static const _trackColor = Color(0xFFEDEEEF);

  static const _segmentColors = [
    Color(0xFF88D982),
    Color(0xFFB3C5FF),
    Color(0xFFFF524C),
  ];

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

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final activePillars =
        pillars.where((pillar) => pillar.outflow + pillar.inflow > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < activePillars.length; i++) ...[
          _buildPillarSection(activePillars[i], _segmentColor(i)),
          if (i != activePillars.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildPillarSection(PillarInsight pillar, Color accent) {
    final isOutflowSide = pillar.outflow > 0;
    final total = isOutflowSide ? pillar.outflow : pillar.inflow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pillar.pillar.name.getOrCrash().toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00113A),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              _formatAmount(total),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00113A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...pillar.envelopes.map(
          (envelope) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildEnvelopeRow(envelope, accent, isOutflowSide),
          ),
        ),
      ],
    );
  }

  Widget _buildEnvelopeRow(
    EnvelopeInsight envelope,
    Color accent,
    bool isOutflowSide,
  ) {
    final name = envelope.category.name.getOrCrash();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E3E4)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconForCategory(name),
              size: 16,
              color: const Color(0xFF757682),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  envelope.breadcrumb,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    height: 4,
                    child: Stack(
                      children: [
                        Container(color: _trackColor),
                        FractionallySizedBox(
                          widthFactor: envelope.shareOfPillar.clamp(0.0, 1.0),
                          child: ColoredBox(color: accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatAmount(isOutflowSide ? envelope.outflow : envelope.inflow),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00113A),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('grocer') || lower.contains('market')) {
      return Icons.shopping_basket_outlined;
    } else if (lower.contains('din') || lower.contains('food')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('rent') || lower.contains('home')) {
      return Icons.home_outlined;
    } else if (lower.contains('fuel') || lower.contains('transport')) {
      return Icons.local_gas_station_outlined;
    } else if (lower.contains('salary') || lower.contains('income')) {
      return Icons.payments_outlined;
    } else if (lower.contains('util') || lower.contains('electric')) {
      return Icons.bolt_outlined;
    }
    return Icons.category_outlined;
  }
}
