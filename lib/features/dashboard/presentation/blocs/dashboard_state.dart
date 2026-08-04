import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.isLoading = true,
    this.totalBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.recentTransactions = const [],
    this.failureOption = const None(),
  });

  final bool isLoading;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> recentTransactions;
  final Option<Failure> failureOption;

  DashboardState copyWith({
    bool? isLoading,
    double? totalBalance,
    double? totalIncome,
    double? totalExpense,
    List<Transaction>? recentTransactions,
    Option<Failure>? failureOption,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      totalBalance: totalBalance ?? this.totalBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      failureOption: failureOption ?? this.failureOption,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        totalBalance,
        totalIncome,
        totalExpense,
        recentTransactions,
        failureOption,
      ];
}
