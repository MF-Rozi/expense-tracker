import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// A modern, hierarchical envelope picker bottom sheet for transaction entry.
///
/// Features:
/// - Filters categories by [targetType] (Expense vs. Income)
/// - Interactive expandable/collapsible tree by Pillar > Sub-Parent > Envelope
/// - Instant search across envelopes, sub-parents, and pillars with
///   breadcrumb results
/// - Highlights the [selectedCategory] with a clear visual active state
/// - Quick "+ Add Envelope" action to create envelopes directly from the modal
class HierarchicalEnvelopePickerSheet extends StatefulWidget {
  const HierarchicalEnvelopePickerSheet({
    required this.targetType,
    required this.onCategorySelected,
    this.selectedCategory,
    super.key,
  });

  final CategoryType targetType;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;

  /// Helper to show this picker in a modal bottom sheet.
  static Future<Category?> show({
    required BuildContext context,
    required CategoryType targetType,
    required CategoryCubit categoryCubit,
    Category? selectedCategory,
  }) {
    return showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: categoryCubit,
        child: HierarchicalEnvelopePickerSheet(
          targetType: targetType,
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            Navigator.of(sheetContext).pop(category);
          },
        ),
      ),
    );
  }

  @override
  State<HierarchicalEnvelopePickerSheet> createState() =>
      _HierarchicalEnvelopePickerSheetState();
}

class _HierarchicalEnvelopePickerSheetState
    extends State<HierarchicalEnvelopePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _collapsedPillars = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _togglePillar(String uuid) {
    setState(() {
      if (_collapsedPillars.contains(uuid)) {
        _collapsedPillars.remove(uuid);
      } else {
        _collapsedPillars.add(uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isExpense = widget.targetType == CategoryType.expense;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF00113A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Envelope',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00113A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isExpense
                                  ? const Color(0xFFFFEAEA)
                                  : const Color(0xFFE6F8EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isExpense
                                  ? 'EXPENSE ENVELOPES'
                                  : 'INCOME ENVELOPES',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: isExpense
                                    ? const Color(0xFFBA1A1A)
                                    : const Color(0xFF1B6B2B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CategoryCubit>(),
                          child: const CategoryFormPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: Color(0xFF00113A),
                  ),
                  label: Text(
                    'New Envelope',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00113A),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF00113A).withValues(alpha: 0.06),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF191C1D),
                ),
                decoration: InputDecoration(
                  hintText: 'Search envelopes, sub-categories, pillars...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757682),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF757682),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF757682),
                          ),
                          onPressed: _searchController.clear,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content List
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter categories for the active target type (Expense/Income)
                final typedCategories = state.allCategories
                    .where((c) => c.type == widget.targetType)
                    .toList();

                if (typedCategories.isEmpty) {
                  return _buildEmptyState(context, isExpense);
                }

                if (_searchQuery.isNotEmpty) {
                  return _buildSearchResults(
                    typedCategories,
                    state.allCategories,
                  );
                }

                return _buildPillarsTree(typedCategories, state.allCategories);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Tree View ───────────────────────────────────

  Widget _buildPillarsTree(
    List<Category> typedCategories,
    List<Category> allCategories,
  ) {
    final pillars = typedCategories.where((c) => c.isRoot).toList();

    if (pillars.isEmpty) {
      return _buildFlatCategoryList(typedCategories, allCategories);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      itemCount: pillars.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final pillar = pillars[index];
        final isCollapsed =
            _collapsedPillars.contains(pillar.uuid.getOrCrash());
        final children = typedCategories
            .where((c) => c.parentId == pillar.uuid)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPillarCard(pillar, children, isCollapsed, allCategories),
            if (!isCollapsed && children.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPillarChildren(children, typedCategories, allCategories),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPillarCard(
    Category pillar,
    List<Category> children,
    bool isCollapsed,
    List<Category> allCategories,
  ) {
    final name = pillar.name.getOrCrash();
    final isSelected = widget.selectedCategory?.uuid == pillar.uuid;
    final totalBudget = _sumBudgetUnder(pillar, allCategories);

    return InkWell(
      onTap: () {
        if (children.isEmpty) {
          widget.onCategorySelected(pillar);
        } else {
          _togglePillar(pillar.uuid.getOrCrash());
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00113A).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00113A)
                : const Color(0xFFE1E3E4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF00113A).withValues(alpha: 0.08),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _buildPillarChip(pillar),
                      if (children.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${children.length} sub-envelopes',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF757682),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (totalBudget > 0) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${totalBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00113A),
                    ),
                  ),
                  Text(
                    '/mo',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF757682),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            if (children.isNotEmpty)
              AnimatedRotation(
                turns: isCollapsed ? 0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 22,
                  color: Color(0xFF757682),
                ),
              )
            else if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 22,
                color: Color(0xFF00113A),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarChildren(
    List<Category> children,
    List<Category> typedCategories,
    List<Category> allCategories,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: children.map((child) {
          final subChildren = typedCategories
              .where((c) => c.parentId == child.uuid)
              .toList();

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnvelopeRow(child, allCategories),
                if (subChildren.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 6),
                    child: Column(
                      children: subChildren.map((subChild) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: _buildEnvelopeRow(subChild, allCategories),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnvelopeRow(Category category, List<Category> allCategories) {
    final name = category.name.getOrCrash();
    final isSelected = widget.selectedCategory?.uuid == category.uuid;
    final budget = category.expectedMonthlyBudget;

    return InkWell(
      onTap: () => widget.onCategorySelected(category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00113A).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00113A)
                : const Color(0xFFE1E3E4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00113A).withValues(alpha: 0.12)
                    : const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForChild(name),
                size: 16,
                color: isSelected
                    ? const Color(0xFF00113A)
                    : const Color(0xFF5A5C66),
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
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.behavioralModifier.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: const Color(0xFF757682),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (budget > 0) ...[
              Text(
                '\$${budget.toStringAsFixed(0)}',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00113A),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFF00113A),
              ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────── Search Results ────────────────────────────────

  Widget _buildSearchResults(
    List<Category> typedCategories,
    List<Category> allCategories,
  ) {
    final matches = typedCategories.where((c) {
      final name = c.name.getOrCrash().toLowerCase();
      final breadcrumb = c.getBreadcrumbPath(allCategories).toLowerCase();
      return name.contains(_searchQuery) || breadcrumb.contains(_searchQuery);
    }).toList();

    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_outlined,
                size: 48,
                color: Color(0xFF757682),
              ),
              const SizedBox(height: 12),
              Text(
                'No envelopes match "$_searchQuery"',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching for another keyword or pillar name',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF757682),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildFlatCategoryList(matches, allCategories);
  }

  Widget _buildFlatCategoryList(
    List<Category> categories,
    List<Category> allCategories,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = widget.selectedCategory?.uuid == category.uuid;
        final breadcrumb = category.getBreadcrumbPath(allCategories);
        final budget = category.expectedMonthlyBudget;

        return InkWell(
          onTap: () => widget.onCategorySelected(category),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00113A).withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00113A)
                    : const Color(0xFFE1E3E4),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00113A).withValues(alpha: 0.12)
                        : const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconForChild(category.name.getOrCrash()),
                    size: 18,
                    color: isSelected
                        ? const Color(0xFF00113A)
                        : const Color(0xFF5A5C66),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (breadcrumb.contains('›')) ...[
                        Text(
                          breadcrumb,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF757682),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        category.name.getOrCrash(),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                    ],
                  ),
                ),
                if (budget > 0) ...[
                  Text(
                    '\$${budget.toStringAsFixed(0)}',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00113A),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Color(0xFF00113A),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────── Empty State ─────────────────────────────────

  Widget _buildEmptyState(BuildContext context, bool isExpense) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF00113A).withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                size: 32,
                color: Color(0xFF00113A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isExpense ? "Expense" : "Income"} Envelopes',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00113A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create envelopes to organize your '
              '${isExpense ? "expenses" : "income"} into hierarchical pillars.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF757682),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CategoryCubit>(),
                      child: const CategoryFormPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(
                'Create First Envelope',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00113A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────── Helpers ───────────────────────────────────

  double _sumBudgetUnder(Category category, List<Category> allCategories) {
    final directChildren = allCategories
        .where((c) => c.parentId == category.uuid)
        .toList();
    if (directChildren.isEmpty) {
      return category.expectedMonthlyBudget;
    }
    return directChildren.fold(
      0,
      (sum, c) => sum + _sumBudgetUnder(c, allCategories),
    );
  }

  Widget _buildPillarChip(Category pillar) {
    final name = pillar.name.getOrCrash().toLowerCase();
    Color chipBg;
    Color chipText;
    if (name.contains('essential') || name.contains('need')) {
      chipBg = const Color(0xFFA0F399);
      chipText = const Color(0xFF217128);
    } else if (name.contains('lifestyle') || name.contains('life')) {
      chipBg = const Color(0xFF002366);
      chipText = const Color(0xFF758DD5);
    } else if (name.contains('revenue') || name.contains('primary')) {
      chipBg = const Color(0xFFD6E3FF);
      chipText = const Color(0xFF003884);
    } else if (name.contains('secondary') || name.contains('side')) {
      chipBg = const Color(0xFFCCE8E0);
      chipText = const Color(0xFF004F44);
    } else if (name.contains('portfolio')) {
      chipBg = const Color(0xFFE8DEF8);
      chipText = const Color(0xFF4A4458);
    } else {
      chipBg = const Color(0xFF5A0006);
      chipText = const Color(0xFFFF524C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        pillar.name.getOrCrash().toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: chipText,
        ),
      ),
    );
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
      return Icons.payments_outlined;
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
        lower.contains('home') ||
        lower.contains('house')) {
      return Icons.home_outlined;
    } else if (lower.contains('util') || lower.contains('electric')) {
      return Icons.bolt_outlined;
    } else if (lower.contains('din') ||
        lower.contains('food') ||
        lower.contains('restaurant') ||
        lower.contains('coffee')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('travel') || lower.contains('flight')) {
      return Icons.flight_outlined;
    } else if (lower.contains('hobbi') || lower.contains('game')) {
      return Icons.sports_esports_outlined;
    } else if (lower.contains('market') ||
        lower.contains('invest') ||
        lower.contains('crypto')) {
      return Icons.bar_chart_outlined;
    } else if (lower.contains('salary') || lower.contains('paycheck')) {
      return Icons.account_balance_wallet_outlined;
    } else if (lower.contains('freelance') || lower.contains('client')) {
      return Icons.work_outline;
    }
    return Icons.category_outlined;
  }
}
