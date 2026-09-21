import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getDashboardSummaryUseCase)
      : super(const DashboardState());

  final GetDashboardSummaryUseCase _getDashboardSummaryUseCase;

  Future<void> loadDashboardData() async {
    emit(
      state.copyWith(
        isLoading: true,
        failureOption: none(),
      ),
    );

    final result = await _getDashboardSummaryUseCase(NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            failureOption: some(failure),
          ),
        );
      },
      (summary) {
        emit(
          state.copyWith(
            isLoading: false,
            totalBalance: summary.totalBalance,
            totalIncome: summary.totalIncome,
            totalExpense: summary.totalExpense,
            recentTransactions: summary.recentTransactions,
            wealthTrajectory: summary.wealthTrajectory,
            failureOption: none(),
          ),
        );
      },
    );
  }
}
