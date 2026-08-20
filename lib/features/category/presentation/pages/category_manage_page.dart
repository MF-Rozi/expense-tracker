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
                        onPillarTap: (pillar) {
                          // Standard expand/collapse handled inside EnvelopeTreeListView,
                          // or selectParent if navigating deeper
                        },
                        onChildTap: (child) {
                          if (!child.isRoot) {
                            context
                                .read<CategoryCubit>()
                                .selectParent(child.uuid.getOrCrash());
                          }
                        },
                        onAddChild: (pillar) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider<CategoryCubit>.value(
                                value: blocContext.read<CategoryCubit>(),
                                child: CategoryFormPage(
                                  activeParentUuid: pillar.uuid.getOrCrash(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
}
