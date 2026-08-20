import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark-blue gradient card showing the total allocated budget and a
/// three-segment distribution bar for Essential, Lifestyle, and Growth.
///
/// Mirrors the `glass-gradient` + progress bar pattern from the HTML mockup
/// (category-new-design.html, lines 921–956).
class PortfolioDistributionCard extends StatelessWidget {
  const PortfolioDistributionCard({
    required this.pillars,
    required this.pillarBudgets,
    required this.totalBudget,
    super.key,
  });

  /// The root-level pillars (Level 1 categories, typically Essential,
  /// Lifestyle, and Growth for expense type).
  final List<Category> pillars;

  /// Maps each pillar's UUID string to its aggregated budget.
  final Map<String, double> pillarBudgets;

  /// Total allocated budget across all envelopes.
  final double totalBudget;

  // Design token colours from the HTML mockup.
  static const _cardGradientStart = Color(0xFF00113A); // primary
  static const _cardGradientEnd = Color(0xFF002366); // primary-container

  // Segment colours matching the HTML mockup distribution bar:
  //   Essential  → secondary-fixed  (#a3f69c)
  //   Lifestyle  → primary-fixed-dim (#b3c5ff)
  //   Growth     → on-tertiary-container (#ff524c)
  static const _essentialColor = Color(0xFF88D982); // secondary-fixed-dim
  static const _lifestyleColor = Color(0xFFB3C5FF); // primary-fixed-dim
  static const _growthColor = Color(0xFFFF524C); // on-tertiary-container

  Color _segmentColor(int index) {
    switch (index % 3) {
      case 0:
        return _essentialColor;
      case 1:
        return _lifestyleColor;
      case 2:
      default:
        return _growthColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardGradientStart, _cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _cardGradientStart.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Shimmer sheen overlay (static; animation omitted for widget
            // isolation — the page can wrap with AnimatedContainer if desired).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTotalBudgetRow(),
                  const SizedBox(height: 20),
                  _buildDistributionBar(),
                  const SizedBox(height: 16),
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Portfolio Distribution',
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildTotalBudgetRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            '\$${totalBudget.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        // Decorative bar chart icon (mirrors HTML bars: w-1.5 h-6/10/4)
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildMiniBar(height: 16, opacity: 0.2),
            const SizedBox(width: 3),
            _buildMiniBar(height: 28, opacity: 1),
            const SizedBox(width: 3),
            _buildMiniBar(height: 10, opacity: 0.4),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniBar({required double height, required double opacity}) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _buildDistributionBar() {
    if (totalBudget == 0 || pillars.isEmpty) {
      // Empty state: single grey bar
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            for (int i = 0; i < pillars.length; i++) ...[
              Builder(
                builder: (context) {
                  final pillarId = pillars[i].uuid.getOrCrash();
                  final budget = pillarBudgets[pillarId] ?? 0.0;
                  final fraction =
                      totalBudget > 0 ? (budget / totalBudget) : 0.0;
                  return Flexible(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Container(color: _segmentColor(i)),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    if (pillars.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < pillars.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _buildLegendItem(pillars[i], i)),
        ],
      ],
    );
  }

  Widget _buildLegendItem(Category pillar, int index) {
    final pillarId = pillar.uuid.getOrCrash();
    final budget = pillarBudgets[pillarId] ?? 0.0;
    final pct = totalBudget > 0 ? ((budget / totalBudget) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pillar.name.getOrCrash().toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$pct%',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
