import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/category/presentation/widgets/category_list.dart';
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
            ? state.allCategories.firstWhere(
                (c) => c.uuid.getOrCrash() == state.activeParentUuid,
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
                      activeCategory?.name.getOrCrash() ?? 'Root Categories',
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

                      // Stitch Premium Layout Card Banner
                      _PortfolioDistributionCard(
                        activeEnvelopesCount: state.allCategories.length,
                      ),

                      const SizedBox(height: 24),

                      // Category List Grid
                      CategoryList(
                        categories: state.currentViewCategories,
                        onCategoryTap: (category) {
                          context
                              .read<CategoryCubit>()
                              .selectCategory(category.uuid.getOrCrash());
                        },
                        onAddTap: () {
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
                        onEditTap: (category) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider<CategoryCubit>.value(
                                value: blocContext.read<CategoryCubit>(),
                                child: CategoryFormPage(
                                  activeParentUuid: state.activeParentUuid,
                                  categoryToEdit: category,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Space for bottom nav/FAB
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
                'Add Category',
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

class _PortfolioDistributionCard extends StatelessWidget {
  const _PortfolioDistributionCard({required this.activeEnvelopesCount});

  final int activeEnvelopesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00113A), Color(0xFF002366)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00113A).withValues(alpha: 0.1),
            blurRadius: 48,
            offset: const Offset(0, 32),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Distribution'.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$activeEnvelopesCount',
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Active Envelopes',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Nested Color Distribution Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 8,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Expanded(
                    flex: 40,
                    child: Container(
                      color: const Color(0xFFA0F399),
                    ), // secondary-container
                  ),
                  Expanded(
                    flex: 25,
                    child: Container(
                      color: const Color(0xFFFFB3AC),
                    ), // tertiary-fixed-dim
                  ),
                  Expanded(
                    flex: 20,
                    child: Container(
                      color: const Color(0xFFB3C5FF),
                    ), // inverse-primary
                  ),
                  Expanded(
                    flex: 15,
                    child:
                        Container(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
