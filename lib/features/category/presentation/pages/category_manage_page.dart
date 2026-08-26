import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/category/presentation/widgets/envelope_tree_list_view.dart';
import 'package:expense_tracker/features/category/presentation/widgets/portfolio_distribution_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryManagePage extends StatelessWidget {
  const CategoryManagePage({super.key});

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

  double _sumBudgetUnder(Category category, List<Category> allCategories) {
    final directChildren = allCategories
        .where((c) => c.parentId?.getOrCrash() == category.uuid.getOrCrash())
        .toList();
    if (directChildren.isEmpty) {
      return category.expectedMonthlyBudget;
    }
    return directChildren.fold(
      0,
      (sum, c) => sum + _sumBudgetUnder(c, allCategories),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BuildContext blocContext,
    Category category, {
    bool popNavAfter = false,
  }) async {
    final categoryCubit = blocContext.read<CategoryCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Envelope',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete '
          '"${category.name.getOrCrash()}" and all its nested sub-envelopes?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF757682)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await categoryCubit.deleteCategory(
        category.uuid.getOrCrash(),
      );
      if (popNavAfter) {
        categoryCubit.goBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (blocContext, state) {
        final activeCategory = state.activeParentUuid != null
            ? state.allCategories.cast<Category?>().firstWhere(
                  (c) => c?.uuid.getOrCrash() == state.activeParentUuid,
                  orElse: () => null,
                )
            : null;

        return PopScope(
          canPop: state.navigationStack.isEmpty,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            blocContext.read<CategoryCubit>().goBack();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA), // surface
            body: CustomScrollView(
              slivers: [
                // Top App Bar Area
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor:
                      const Color(0xFFF8FAFC).withValues(alpha: 0.8),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF00113A),
                    onPressed: () {
                      if (state.navigationStack.isNotEmpty) {
                        blocContext.read<CategoryCubit>().goBack();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    title: Text(
                      activeCategory?.name.getOrCrash() ?? 'Envelopes',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: const Color(0xFF00113A), // primary
                        letterSpacing: -0.5,
                      ),
                    ),
                    centerTitle: false,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined),
                      color: const Color(0xFF00113A),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (activeCategory == null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Architecture'.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: const Color(0xFF757682), // outline
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Portfolio Distribution Card Header
                        PortfolioDistributionCard(
                          pillars: state.activePillars,
                          pillarBudgets: state.pillarBudgets,
                          totalBudget: state.totalBudget,
                        ),

                        const SizedBox(height: 32),

                        // Envelope Tree List View
                        EnvelopeTreeListView(
                          allCategories: state.allCategories,
                          onChildTap: (child) {
                            if (!child.isRoot) {
                              blocContext
                                  .read<CategoryCubit>()
                                  .selectParent(child.uuid.getOrCrash());
                            }
                          },
                          onAddChild: (pillar) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    BlocProvider<CategoryCubit>.value(
                                  value: blocContext.read<CategoryCubit>(),
                                  child: CategoryFormPage(
                                    activeParentUuid: pillar.uuid.getOrCrash(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        _buildActiveParentCard(
                          context,
                          blocContext,
                          activeCategory,
                          state,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SUB-ENVELOPES',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: const Color(0xFF757682),
                              ),
                            ),
                            Text(
                              '${state.currentViewCategories.length} items',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF757682),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (state.currentViewCategories.isEmpty)
                          _buildEmptySubEnvelopesState(activeCategory)
                        else
                          ...state.currentViewCategories.map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSubEnvelopeItem(
                                context,
                                blocContext,
                                child,
                                state,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 100), // Space for FAB
                    ]),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider<CategoryCubit>.value(
                      value: blocContext.read<CategoryCubit>(),
                      child: CategoryFormPage(
                        activeParentUuid: state.activeParentUuid,
                      ),
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF00113A),
              foregroundColor: Colors.white,
              label: Text(
                'Add Envelope',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveParentCard(
    BuildContext context,
    BuildContext blocContext,
    Category activeCategory,
    CategoryState state,
  ) {
    final parentPillar = activeCategory.parentId != null
        ? state.allCategories.cast<Category?>().firstWhere(
              (c) => c?.uuid == activeCategory.parentId,
              orElse: () => null,
            )
        : null;

    final totalBudget = _sumBudgetUnder(activeCategory, state.allCategories);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00113A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF00113A).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForChild(activeCategory.name.getOrCrash()),
                  size: 22,
                  color: const Color(0xFF00113A),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (parentPillar != null)
                      Text(
                        parentPillar.name.getOrCrash().toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: const Color(0xFF757682),
                        ),
                      ),
                    Text(
                      activeCategory.name.getOrCrash(),
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF191C1D),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: const Color(0xFF757682),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<CategoryCubit>.value(
                        value: blocContext.read<CategoryCubit>(),
                        child: CategoryFormPage(
                          categoryToEdit: activeCategory,
                          activeParentUuid:
                              activeCategory.parentId?.getOrCrash(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFFBA1A1A),
                onPressed: () {
                  _confirmDelete(
                    context,
                    blocContext,
                    activeCategory,
                    popNavAfter: true,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEDEEEF)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F5),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  activeCategory.behavioralModifier.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: const Color(0xFF444650),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${totalBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00113A),
                    ),
                  ),
                  Text(
                    'TOTAL ALLOCATED',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: const Color(0xFF757682),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubEnvelopeItem(
    BuildContext context,
    BuildContext blocContext,
    Category child,
    CategoryState state,
  ) {
    final name = child.name.getOrCrash();
    final budget = _sumBudgetUnder(child, state.allCategories);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00113A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconForChild(name),
              size: 18,
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
                    fontSize: 14,
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00113A),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: const Color(0xFF757682),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<CategoryCubit>.value(
                    value: blocContext.read<CategoryCubit>(),
                    child: CategoryFormPage(
                      categoryToEdit: child,
                      activeParentUuid: child.parentId?.getOrCrash(),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: const Color(0xFFBA1A1A),
            onPressed: () {
              _confirmDelete(context, blocContext, child);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySubEnvelopesState(Category activeCategory) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: Color(0xFF757682),
            ),
            const SizedBox(height: 12),
            Text(
              'No sub-envelopes yet',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nested envelopes inside "${activeCategory.name.getOrCrash()}" '
              'will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF757682),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
