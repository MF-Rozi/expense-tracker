import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/watch_transactions_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._getDashboardSummaryUseCase,
    this._watchTransactionsUseCase,
  ) : super(const DashboardState()) {
    _init();
  }

  final GetDashboardSummaryUseCase _getDashboardSummaryUseCase;
  final WatchTransactionsUseCase _watchTransactionsUseCase;

  StreamSubscription<Either<Failure, List<Transaction>>>?
      _transactionsSubscription;

  void _init() {
    _transactionsSubscription =
        _watchTransactionsUseCase(NoParams()).listen((result) {
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoading: false,
              failureOption: some(failure),
            ),
          );
        },
        (_) {
          loadDashboardData(showLoadingIndicator: false);
        },
      );
    });
  }

  Future<void> loadDashboardData({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      emit(
        state.copyWith(
          isLoading: true,
          failureOption: none(),
        ),
      );
    }

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

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
