import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inline summary card displayed at the bottom of the creation form.
///
/// Shows the user where the new envelope will sit in the hierarchy
/// (Pillar > Sub-Parent) and its relative percentage of total budget.
///
/// Mirrors the "Hierarchy Insight" card in the HTML mockup
/// (category-new-design.html, lines 684–699).
class HierarchyInsightCard extends StatelessWidget {
  const HierarchyInsightCard({
    required this.envelopeName,
    required this.pillar,
    required this.subParent,
    required this.totalBudget,
    required this.envelopeBudget,
    super.key,
  });

  /// The name being entered for the new envelope.
  final String envelopeName;

  /// The selected Level 1 pillar category.
  final Category? pillar;

  /// The selected Level 2 sub-parent category.
  final Category? subParent;

  /// The total budget across all envelopes (for percentage calculation).
  final double totalBudget;

  /// The budget value entered for the new envelope.
  final double envelopeBudget;

  // Design tokens from HTML mockup
  static const _primaryColor = Color(0xFF00113A);
  static const _outlineVariant = Color(0xFFC5C6D2);

  String get _hierarchyPath {
    final pillarName = pillar?.name.getOrCrash() ?? '—';
    final subParentName = subParent?.name.getOrCrash() ?? '—';
    return '$pillarName > $subParentName';
  }

  String get _percentageText {
    if (totalBudget <= 0 || envelopeBudget <= 0) return '';
    final pct = ((envelopeBudget / totalBudget) * 100).toStringAsFixed(0);
    return ' It represents $pct% of your planned spending.';
  }

  @override
  Widget build(BuildContext context) {
    final name =
        envelopeName.isNotEmpty ? "'$envelopeName'" : 'The new envelope';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildTextContent(name)),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00113A), Color(0xFF002366)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.hub_outlined, color: Colors.white, size: 18),
    );
  }

  Widget _buildTextContent(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hierarchy Insight',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00113A),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF444650), // on-surface-variant
              height: 1.5,
            ),
            children: [
              TextSpan(text: '$name will be nested under '),
              TextSpan(
                text: _hierarchyPath,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
              TextSpan(text: '.$_percentageText'),
            ],
          ),
        ),
      ],
    );
  }
}
