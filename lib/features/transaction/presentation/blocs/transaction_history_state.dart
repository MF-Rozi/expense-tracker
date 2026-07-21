import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:intl/intl.dart';

extension DateTimeGroupFormatting on DateTime {
  String toGroupKey() {
    final local = toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(local.year, local.month, local.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(local);
    }
  }
}

class TransactionHistoryState extends Equatable {
  const TransactionHistoryState({
    this.groupedTransactions = const {},
    this.activeFlow = TransactionFlowType.all,
    this.searchQuery,
    this.activeCategoryId,
    this.startDate,
    this.endDate,
    this.isLoading = true,
    this.error,
  });

  final Map<String, List<Transaction>> groupedTransactions;
  final TransactionFlowType activeFlow;
  final String? searchQuery;
  final String? activeCategoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final String? error;

  TransactionHistoryState copyWith({
    Map<String, List<Transaction>>? groupedTransactions,
    TransactionFlowType? activeFlow,
    Object? searchQuery = const Object(),
    Object? activeCategoryId = const Object(),
    Object? startDate = const Object(),
    Object? endDate = const Object(),
    bool? isLoading,
    Object? error = const Object(),
  }) {
    return TransactionHistoryState(
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      activeFlow: activeFlow ?? this.activeFlow,
      searchQuery: searchQuery == const Object()
          ? this.searchQuery
          : (searchQuery as String?),
      activeCategoryId: activeCategoryId == const Object()
          ? this.activeCategoryId
          : (activeCategoryId as String?),
      startDate: startDate == const Object()
          ? this.startDate
          : (startDate as DateTime?),
      endDate:
          endDate == const Object() ? this.endDate : (endDate as DateTime?),
      isLoading: isLoading ?? this.isLoading,
      error: error == const Object() ? this.error : (error as String?),
    );
  }

  @override
  List<Object?> get props => [
        groupedTransactions,
        activeFlow,
        searchQuery,
        activeCategoryId,
        startDate,
        endDate,
        isLoading,
        error,
      ];
}
