import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());

  final TransactionRepository _repository;

  Future<void> loadDashboardData() async {
    emit(
      state.copyWith(
        isLoading: true,
        failureOption: none(),
      ),
    );

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final result = await _repository.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            failureOption: some(failure),
          ),
        );
      },
      (transactions) {
        final totalIncome = transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount.getOrCrash());

        final totalExpense = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount.getOrCrash());

        final totalBalance = totalIncome - totalExpense;
        final recentTransactions = transactions.take(5).toList();

        emit(
          state.copyWith(
            isLoading: false,
            totalBalance: totalBalance,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            recentTransactions: recentTransactions,
            failureOption: none(),
          ),
        );
      },
    );
  }
}
