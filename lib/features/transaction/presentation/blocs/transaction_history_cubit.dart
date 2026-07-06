import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_flow_type.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/get_transactions_use_case.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit(this._getTransactionsUseCase)
      : super(const TransactionHistoryState());

  final GetTransactionsUseCase _getTransactionsUseCase;

  Future<void> fetchTransactions() async {
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
      ),
    );

    final result = await _getTransactionsUseCase(
      GetTransactionsParams(
        startDate: state.startDate,
        endDate: state.endDate,
        searchQuery: state.searchQuery,
        categoryId: state.activeCategoryId,
        flowType: state.activeFlow,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure.toString(),
        ),
      ),
      (transactions) {
        final grouped = <String, List<Transaction>>{};
        for (final transaction in transactions) {
          final key = transaction.date.toGroupKey();
          grouped.putIfAbsent(key, () => []).add(transaction);
        }
        emit(
          state.copyWith(
            groupedTransactions: grouped,
            isLoading: false,
            error: null,
          ),
        );
      },
    );
  }

  void updateSearch(String query) {
    final cleanQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: cleanQuery.isEmpty ? null : cleanQuery,
      ),
    );
    fetchTransactions();
  }

  void updateFlowType(TransactionFlowType flowType) {
    emit(state.copyWith(activeFlow: flowType));
    fetchTransactions();
  }

  void applyFilters(DateTime? start, DateTime? end, String? categoryId) {
    emit(
      state.copyWith(
        startDate: start,
        endDate: end,
        activeCategoryId: categoryId,
      ),
    );
    fetchTransactions();
  }
}
