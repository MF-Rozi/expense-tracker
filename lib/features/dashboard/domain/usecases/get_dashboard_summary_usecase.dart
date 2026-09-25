import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/wealth_trajectory.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

/// Aggregates all transactions to construct a [DashboardSummary] containing:
/// - Current calendar month's totals (income, expense, balance)
/// - Top 5 most recent transactions
/// - Rolling 5-month [WealthTrajectory] (months M-4 through M) with
///   month-over-month net worth growth rate and contextual copy.
@lazySingleton
class GetDashboardSummaryUseCase extends UseCase<DashboardSummary, NoParams> {
  GetDashboardSummaryUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, DashboardSummary>> call(NoParams params) async {
    return executeWithDate(DateTime.now());
  }

  /// Package-private or testing entrypoint allowing deterministic
  /// date injection.
  Future<Either<Failure, DashboardSummary>> executeWithDate(
    DateTime now,
  ) async {
    // Fetch all transactions
    final result = await _repository.getTransactions();

    return result.map((allTransactions) {
      // Sort transactions descending by date (most recent first)
      final sortedTransactions = List<Transaction>.from(allTransactions)
        ..sort((a, b) => b.date.compareTo(a.date));

      final recentTransactions = sortedTransactions.take(5).toList();

      // Current calendar month bounds
      final currentMonthStart = DateTime(now.year, now.month);
      final nextMonthStart = (now.month == 12)
          ? DateTime(now.year + 1)
          : DateTime(now.year, now.month + 1);

      // Current month aggregates
      final currentMonthTx = sortedTransactions.where((t) {
        return !t.date.isBefore(currentMonthStart) &&
            t.date.isBefore(nextMonthStart);
      });

      var currentMonthIncome = 0.0;
      var currentMonthExpense = 0.0;

      for (final tx in currentMonthTx) {
        final amount = tx.amount.getOrCrash();
        switch (tx.type) {
          case TransactionType.income:
            currentMonthIncome += amount;
          case TransactionType.expense:
            currentMonthExpense += amount;
          case TransactionType.investment:
            // Investments are capital deployment, not operational outflow
            break;
        }
      }

      final currentMonthBalance = currentMonthIncome - currentMonthExpense;

      // 5-month rolling wealth trajectory
      final trajectory = _buildWealthTrajectory(sortedTransactions, now);

      return DashboardSummary(
        totalBalance: currentMonthBalance,
        totalIncome: currentMonthIncome,
        totalExpense: currentMonthExpense,
        recentTransactions: recentTransactions,
        wealthTrajectory: trajectory,
      );
    });
  }

  WealthTrajectory _buildWealthTrajectory(
    List<Transaction> transactions,
    DateTime now,
  ) {
    // Generate the 5 months: M-4, M-3, M-2, M-1, M
    final monthDates = <DateTime>[];
    for (var i = 4; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i);
      monthDates.add(DateTime(m.year, m.month));
    }

    // Cumulative balance for each month cutoff
    final points = <TrajectoryPoint>[];
    for (var i = 0; i < monthDates.length; i++) {
      final monthDate = monthDates[i];
      final isCurrent = i == monthDates.length - 1;

      // End of this month (exclusive cutoff is the start of next month,
      // or now if current month)
      final nextMonth = (monthDate.month == 12)
          ? DateTime(monthDate.year + 1)
          : DateTime(monthDate.year, monthDate.month + 1);

      final cutoff = isCurrent ? now : nextMonth;

      var cumulativeNetWorth = 0.0;
      for (final tx in transactions) {
        if (!tx.date.isAfter(cutoff)) {
          final amount = tx.amount.getOrCrash();
          switch (tx.type) {
            case TransactionType.income:
              cumulativeNetWorth += amount;
            case TransactionType.expense:
              cumulativeNetWorth -= amount;
            case TransactionType.investment:
              // Balance remains in net worth (asset)
              break;
          }
        }
      }

      points.add(
        TrajectoryPoint(
          month: monthDate,
          netWorth: cumulativeNetWorth,
          isCurrentMonth: isCurrent,
        ),
      );
    }

    final currentNetWorth = points.last.netWorth;
    final prevNetWorth = points[points.length - 2].netWorth;

    double? growthPercentage;
    String headlineDescription;

    if (transactions.isEmpty) {
      headlineDescription = 'No transaction data yet.';
    } else if (prevNetWorth == 0) {
      if (currentNetWorth > 0) {
        headlineDescription = 'First month of positive net worth!';
      } else if (currentNetWorth < 0) {
        headlineDescription = 'Net worth is negative this month.';
      } else {
        headlineDescription = 'Your net worth is steady this month.';
      }
    } else {
      final delta = currentNetWorth - prevNetWorth;
      final pct = (delta / prevNetWorth.abs()) * 100;
      growthPercentage = pct;

      final formattedPct = pct.abs().toStringAsFixed(1);
      if (pct > 0.05) {
        headlineDescription =
            'Your net worth increased by $formattedPct% this month.';
      } else if (pct < -0.05) {
        headlineDescription =
            'Your net worth decreased by $formattedPct% this month.';
      } else {
        headlineDescription = 'Your net worth is steady this month.';
      }
    }

    return WealthTrajectory(
      points: points,
      growthPercentage: growthPercentage,
      headlineDescription: headlineDescription,
    );
  }
}
