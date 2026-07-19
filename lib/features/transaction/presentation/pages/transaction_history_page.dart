import 'dart:async';

import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_history_cubit.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_history_state.dart';
import 'package:expense_tracker/features/transaction/presentation/widgets/transaction_history_filter_sheet.dart';
import 'package:expense_tracker/injector.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionHistoryCubit>(
          create: (context) =>
              getIt<TransactionHistoryCubit>()..fetchTransactions(),
        ),
        BlocProvider<CategoryCubit>.value(
          value: getIt<CategoryCubit>(),
        ),
      ],
      child: const TransactionHistoryView(),
    );
  }
}

class TransactionHistoryView extends StatefulWidget {
  const TransactionHistoryView({super.key});

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final initialQuery =
        context.read<TransactionHistoryCubit>().state.searchQuery ?? '';
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<TransactionHistoryCubit>().updateSearch(query);
      }
    });
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<TransactionHistoryCubit>()),
            BlocProvider.value(value: context.read<CategoryCubit>()),
          ],
          child: TransactionHistoryFilterSheet(
            initialCategoryId:
                context.read<TransactionHistoryCubit>().state.activeCategoryId,
            initialStartDate:
                context.read<TransactionHistoryCubit>().state.startDate,
            initialEndDate:
                context.read<TransactionHistoryCubit>().state.endDate,
            onApply: (start, end, categoryId) {
              context
                  .read<TransactionHistoryCubit>()
                  .applyFilters(start, end, categoryId);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
          builder: (context, state) {
            final grouped = state.groupedTransactions;
            final slivers = <Widget>[
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ledger History',
                        style: GoogleFonts.manrope(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00113A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chronological view of your sovereign capital',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF444650),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Filter by merchant or category...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF757682),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF757682),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00113A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Flow Chips Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: _buildFlowChips(state),
                ),
              ),
            ];

            if (state.isLoading && grouped.isEmpty) {
              slivers.add(
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00113A),
                    ),
                  ),
                ),
              );
            } else if (state.error != null && grouped.isEmpty) {
              slivers.add(
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.error!,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFBA1A1A),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            } else if (grouped.isEmpty) {
              slivers.add(
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color:
                                const Color(0xFF757682).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No movements recorded',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00113A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF444650),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              for (final dateKey in grouped.keys) {
                final transactions = grouped[dateKey] ?? [];

                slivers
                  ..add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Row(
                          children: [
                            Text(
                              dateKey.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: const Color(0xFF757682),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Divider(
                                color: Color(0x1F757682),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  ..add(
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transaction = transactions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TransactionCard(transaction: transaction),
                            );
                          },
                          childCount: transactions.length,
                        ),
                      ),
                    ),
                  );
              }
              // Add a bit of space at the bottom
              slivers.add(
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              );
            }

            return CustomScrollView(
              slivers: slivers,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlowChips(TransactionHistoryState state) {
    final flows = [
      (TransactionFlowType.all, 'All Flows'),
      (TransactionFlowType.expense, 'Expenses'),
      (TransactionFlowType.income, 'Income'),
      (TransactionFlowType.investment, 'Investment'),
    ];

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          ...flows.map((flow) {
            final isSelected = state.activeFlow == flow.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => context
                    .read<TransactionHistoryCubit>()
                    .updateFlowType(flow.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00113A)
                        : const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      flow.$2,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF444650),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () => _openFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.tune,
                size: 20,
                color: Color(0xFF00113A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final categories = context.read<CategoryCubit>().state.allCategories;
    final category = categories.firstWhere(
      (c) => c.uuid.getOrCrash() == transaction.categoryUuid.getOrCrash(),
      orElse: () => Category(
        uuid: UniqueId(''),
        name: StringSingleLine('Uncategorized'),
        isSynced: false,
        updatedAt: DateTime.now(),
      ),
    );
    final categoryName = category.name.getOrCrash();
    final icon = _getCategoryIcon(categoryName);
    final iconColor = _getCategoryColor(categoryName);

    final isCredit = transaction.type == TransactionType.income;
    final amountColor =
        isCredit ? const Color(0xFF1B6D24) : const Color(0xFFBA1A1A);
    final prefix = isCredit ? '+' : '-';
    final formattedAmount = NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0,
    ).format(transaction.amount.getOrCrash());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await context.push('/transactions', extra: transaction);
            if (context.mounted) {
              await context.read<TransactionHistoryCubit>().fetchTransactions();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description.getOrCrash(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF00113A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$categoryName • '
                        '${DateFormat('h:mm a').format(
                          transaction.date.toLocal(),
                        )}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF444650),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$prefix$formattedAmount',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('shop')) {
      return Icons.shopping_bag_outlined;
    } else if (lowerName.contains('din') || lowerName.contains('food')) {
      return Icons.restaurant_outlined;
    } else if (lowerName.contains('hous') || lowerName.contains('home')) {
      return Icons.home_outlined;
    } else if (lowerName.contains('trans') || lowerName.contains('car')) {
      return Icons.directions_car_outlined;
    } else if (lowerName.contains('health')) {
      return Icons.monitor_heart_outlined;
    }
    return Icons.category_outlined;
  }

  Color _getCategoryColor(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('shop')) {
      return const Color(0xFF00113A);
    } else if (lowerName.contains('din') || lowerName.contains('food')) {
      return const Color(0xFF1B6D24);
    } else if (lowerName.contains('hous') || lowerName.contains('home')) {
      return const Color(0xFFBA1A1A);
    } else if (lowerName.contains('trans') || lowerName.contains('car')) {
      return const Color(0xFF002366);
    } else if (lowerName.contains('health')) {
      return const Color(0xFFBA1A1A);
    }
    return const Color(0xFF00113A);
  }
}
