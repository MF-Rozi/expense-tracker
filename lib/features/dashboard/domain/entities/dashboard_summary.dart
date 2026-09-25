import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/wealth_trajectory.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';

/// Aggregated summary model for the home dashboard screen.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
    required this.wealthTrajectory,
  });

  /// Net balance for the current calendar month (totalIncome - totalExpense).
  final double totalBalance;

  /// Inflow sum for the current calendar month.
  final double totalIncome;

  /// Outflow sum for the current calendar month.
  final double totalExpense;

  /// Up to 5 most recent transactions overall.
  final List<Transaction> recentTransactions;

  /// 5-month wealth trajectory timeline and growth metrics.
  final WealthTrajectory wealthTrajectory;

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        recentTransactions,
        wealthTrajectory,
      ];
}
