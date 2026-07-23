import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_history_cubit.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({required this.transaction, super.key});

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
            await context.push('/transaction/new', extra: transaction);
            if (context.mounted) {
              try {
                await context
                    .read<TransactionHistoryCubit>()
                    .fetchTransactions();
              } catch (_) {
                // If not in a context with TransactionHistoryCubit
                // (e.g. Dashboard), do nothing.
              }
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
