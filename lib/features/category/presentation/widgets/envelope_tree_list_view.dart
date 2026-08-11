import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Expandable tree list view for the Category Architecture screen.
///
/// Renders Level 1 pillars as section headers and their Level 2 sub-parents
/// (or Level 3 envelopes) as indented child rows with the `stagger-line` /
/// `stagger-line-item` visual decoration from the HTML mockup
/// (category-new-design.html, lines 874–892, 961–1120).
///
/// Only two levels of nesting are rendered here (Pillar → Sub-Parent /
/// direct Envelopes). A third level requires the user to tap a sub-parent
/// row and navigate deeper — this widget delegates that via [onChildTap].
class EnvelopeTreeListView extends StatefulWidget {
  const EnvelopeTreeListView({
    required this.allCategories,
    this.onPillarTap,
    this.onChildTap,
    this.onAddChild,
    super.key,
  });

  /// The complete flat list of all categories (all levels).
  final List<Category> allCategories;

  /// Called when the user taps a pillar header row.
  final void Function(Category pillar)? onPillarTap;

  /// Called when the user taps a child row (sub-parent or leaf envelope).
  final void Function(Category child)? onChildTap;

  /// Called when the user taps the add button on a pillar section.
  final void Function(Category pillar)? onAddChild;

  @override
  State<EnvelopeTreeListView> createState() => _EnvelopeTreeListViewState();
}

class _EnvelopeTreeListViewState extends State<EnvelopeTreeListView> {
  /// Tracks which pillar UUIDs are collapsed. Pillars start expanded.
  final Set<String> _collapsed = {};

  List<Category> get _pillars =>
      widget.allCategories.where((c) => c.isRoot).toList();

  List<Category> _childrenOf(Category parent) {
    final parentId = parent.uuid.getOrCrash();
    return widget.allCategories
        .where((c) => c.parentId?.getOrCrash() == parentId)
        .toList();
  }

  void _togglePillar(String uuid) {
    setState(() {
      if (_collapsed.contains(uuid)) {
        _collapsed.remove(uuid);
      } else {
        _collapsed.add(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pillars.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pillars.length,
      separatorBuilder: (_, __) => const SizedBox(height: 32),
      itemBuilder: (context, index) => _buildPillarSection(_pillars[index]),
    );
  }

  // ──────────────────────────── Pillar Section ──────────────────────────────

  Widget _buildPillarSection(Category pillar) {
    final pillarId = pillar.uuid.getOrCrash();
    final isCollapsed = _collapsed.contains(pillarId);
    final children = _childrenOf(pillar);

    // Compute aggregated budget for display
    double totalBudget = 0;
    for (final child in children) {
      totalBudget += _sumBudgetUnder(child);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPillarHeader(pillar, totalBudget, isCollapsed, children.isEmpty),
        if (!isCollapsed && children.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildChildrenContainer(children),
        ],
      ],
    );
  }

  Widget _buildPillarHeader(
    Category pillar,
    double totalBudget,
    bool isCollapsed,
    bool hasNoChildren,
  ) {
    final name = pillar.name.getOrCrash();
    final pillarId = pillar.uuid.getOrCrash();

    return InkWell(
      onTap: () {
        _togglePillar(pillarId);
        widget.onPillarTap?.call(pillar);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Pillar icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE1E3E4), // surface-container-highest
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForPillar(name),
                size: 20,
                color: const Color(0xFF00113A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  _buildPillarChip(pillar),
                ],
              ),
            ),
            // Budget + collapse indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalBudget.toStringAsFixed(0)}',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C1D),
                  ),
                ),
                Text(
                  'ALLOCATED',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: const Color(0xFF757682),
                  ),
                ),
              ],
            ),
            if (!hasNoChildren) ...[
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isCollapsed ? 0 : 0.5,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Color(0xFF757682),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPillarChip(Category pillar) {
    // Reuse existing pillar names to drive chip color
    final name = pillar.name.getOrCrash().toLowerCase();
    Color chipBg;
    Color chipText;
    if (name.contains('essential') || name.contains('need')) {
      chipBg = const Color(0xFFA0F399); // secondary-container
      chipText = const Color(0xFF217128); // on-secondary-container
    } else if (name.contains('lifestyle') || name.contains('life')) {
      chipBg = const Color(0xFF002366); // primary-container
      chipText = const Color(0xFF758DD5); // on-primary-container
    } else {
      chipBg = const Color(0xFF5A0006); // tertiary-container
      chipText = const Color(0xFFFF524C); // on-tertiary-container
    }

    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        pillar.name.getOrCrash().toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: chipText,
        ),
      ),
    );
  }

  // ─────────────────────────── Children Container ───────────────────────────

  /// The indented list with the `stagger-line` + `stagger-line-item` visual.
  Widget _buildChildrenContainer(List<Category> children) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: CustomPaint(
        painter: _StaggerLinePainter(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 8),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _StaggerLineItemWrapper(
                  child: _buildChildRow(children[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildRow(Category child) {
    final name = child.name.getOrCrash();
    final budget = _sumBudgetUnder(child);

    return InkWell(
      onTap: () => widget.onChildTap?.call(child),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // surface-container-lowest
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F5), // surface-container-low
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForChild(name),
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
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  Text(
                    child.behavioralModifier.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: const Color(0xFF757682),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${budget.toStringAsFixed(0)}',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00113A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────── Helpers ──────────────────────────────────

  /// Recursively sums expected monthly budgets for [category] and all its
  /// descendants (so Pillars/Sub-Parents show aggregated totals).
  double _sumBudgetUnder(Category category) {
    final directChildren = _childrenOf(category);
    if (directChildren.isEmpty) {
      return category.expectedMonthlyBudget;
    }
    return directChildren.fold(0, (sum, c) => sum + _sumBudgetUnder(c));
  }

  IconData _iconForPillar(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('essential') || lower.contains('need')) {
      return Icons.account_balance_outlined;
    } else if (lower.contains('lifestyle') || lower.contains('life')) {
      return Icons.beach_access_outlined;
    } else if (lower.contains('growth') || lower.contains('invest')) {
      return Icons.trending_up;
    } else if (lower.contains('revenue')) {
      return Icons.account_balance_outlined;
    } else if (lower.contains('secondary') || lower.contains('income')) {
      return Icons.show_chart;
    } else if (lower.contains('portfolio')) {
      return Icons.bar_chart_outlined;
    }
    return Icons.folder_outlined;
  }

  IconData _iconForChild(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mortgage') ||
        lower.contains('rent') ||
        lower.contains('home')) {
      return Icons.home_outlined;
    } else if (lower.contains('util') || lower.contains('electric')) {
      return Icons.bolt_outlined;
    } else if (lower.contains('din') ||
        lower.contains('food') ||
        lower.contains('restaurant')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('travel') || lower.contains('flight')) {
      return Icons.flight_outlined;
    } else if (lower.contains('hobbi') || lower.contains('game')) {
      return Icons.sports_esports_outlined;
    } else if (lower.contains('market') || lower.contains('invest')) {
      return Icons.bar_chart_outlined;
    }
    return Icons.category_outlined;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(
          'No envelopes yet',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF757682),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── Stagger Line Painters ────────────────────────────────

/// Draws the vertical connector line matching `.stagger-line::before` in CSS.
class _StaggerLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5C6D2).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical line from top to near bottom (leave ~24px gap at bottom)
    canvas.drawLine(
      Offset.zero,
      Offset(0, size.height - 24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wraps each child row and draws the horizontal connector matching
/// `.stagger-line-item::after` in CSS.
class _StaggerLineItemWrapper extends StatelessWidget {
  const _StaggerLineItemWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HorizontalConnectorPainter(),
      child: child,
    );
  }
}

class _HorizontalConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5C6D2).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal connector from left edge to the child card
    canvas.drawLine(
      const Offset(-20, 16),
      const Offset(0, 16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
