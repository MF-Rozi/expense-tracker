import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/category/domain/utils/category_budget_calculator.dart';
import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';
import 'package:expense_tracker/features/streak/domain/repositories/app_open_repository.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:expense_tracker/features/streak/domain/services/streak_engine.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StreakRepository)
class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(
    this._transactionRepository,
    this._localStorage,
    this._appOpenRepository,
    this._categoryRepository, {
    StreakEngine engine = const StreakEngine(),
  }) : _engine = engine;

  final TransactionRepository _transactionRepository;
  final LocalStorage _localStorage;
  final AppOpenRepository _appOpenRepository;
  final CategoryRepository _categoryRepository;
  final StreakEngine _engine;

  static const defaultLookbackYears = 2;

  @override
  Future<Either<Failure, Streak>> getStreak({
    StreakType type = StreakType.tracking,
    DateTime? referenceDate,
  }) async {
    try {
      final now = referenceDate ?? DateTime.now();
      final today = StreakDay.fromDateTime(now);
      final startDate = DateTime(
        now.year - defaultLookbackYears,
        now.month,
        now.day,
      );
      final endDate = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
        999,
      );

      final window = await _localStorage.getStreakWindowDays();
      final minimum = await _localStorage.getStreakMinimumDays();
      final cadence = await _localStorage.getAppOpenCadenceDays();

      switch (type) {
        case StreakType.tracking:
          final config = StreakConfig(
            window: window,
            minimum: minimum,
            cadence: cadence,
          );
          final txResult = await _transactionRepository.getTransactions(
            startDate: startDate,
            endDate: endDate,
          );

          return txResult.fold(
            Left.new,
            (transactions) {
              final qualifyingPeriods = transactions
                  .map((tx) => StreakDay.fromDateTime(tx.date))
                  .toSet();

              final result = _engine.calculate(
                qualifyingPeriods: qualifyingPeriods,
                today: today,
                config: config,
                type: type,
              );

              return Right(result.current);
            },
          );

        case StreakType.noSpend:
          final config = StreakConfig(
            window: window,
            minimum: minimum,
            cadence: cadence,
          );
          final txResult = await _transactionRepository.getTransactions(
            startDate: startDate,
            endDate: endDate,
          );

          return txResult.fold(
            Left.new,
            (transactions) {
              if (transactions.isEmpty) {
                final result = _engine.calculate(
                  qualifyingPeriods: const <StreakPeriod>{},
                  today: today,
                  config: config,
                  type: type,
                );
                return Right(result.current);
              }

              final earliestTx = transactions
                  .map((tx) => tx.date)
                  .reduce((a, b) => a.isBefore(b) ? a : b);
              final startDay = StreakDay.fromDateTime(earliestTx);

              final expenseDays = transactions
                  .where((tx) => tx.type == TransactionType.expense)
                  .map((tx) => StreakDay.fromDateTime(tx.date))
                  .toSet();

              final qualifyingPeriods = <StreakPeriod>{};
              var current =
                  DateTime(startDay.year, startDay.month, startDay.day);
              final target = DateTime(today.year, today.month, today.day);

              while (!current.isAfter(target)) {
                final day = StreakDay.fromDateTime(current);
                if (!expenseDays.contains(day)) {
                  qualifyingPeriods.add(day);
                }
                current =
                    DateTime(current.year, current.month, current.day + 1);
              }

              final result = _engine.calculate(
                qualifyingPeriods: qualifyingPeriods,
                today: today,
                config: config,
                type: type,
              );

              return Right(result.current);
            },
          );

        case StreakType.appOpen:
          // Cadence N drives the window for app-open consistency.
          final config = StreakConfig(
            window: cadence,
            minimum: minimum,
            cadence: cadence,
          );
          final opensResult = await _appOpenRepository.getOpenDates(
            startDate: startDate,
            endDate: endDate,
          );

          return opensResult.fold(
            Left.new,
            (openDates) {
              final qualifyingPeriods =
                  openDates.map(StreakDay.fromDateTime).toSet();

              final result = _engine.calculate(
                qualifyingPeriods: qualifyingPeriods,
                today: today,
                config: config,
                type: type,
              );

              return Right(result.current);
            },
          );

        case StreakType.underBudget:
          final categoriesEither =
              await _categoryRepository.watchCategories().first;
          final txResult = await _transactionRepository.getTransactions(
            startDate: startDate,
            endDate: endDate,
          );

          final failure = categoriesEither.fold((f) => f, (_) => null) ??
              txResult.fold((f) => f, (_) => null);
          if (failure != null) {
            return Left(failure);
          }

          final allCategories =
              categoriesEither.getOrElse(() => const <Category>[]);
          final transactions =
              txResult.getOrElse(() => const <Transaction>[]);

          final totalBudget = CategoryBudgetCalculator.calculateTotalBudget(
            allCategories,
          );

          final nowMonth = StreakMonth(now.year, now.month);
          final lastCompletedMonth = nowMonth.previous();

          final expenseByMonth = <StreakMonth, double>{};
          for (final tx in transactions) {
            if (tx.type == TransactionType.expense) {
              final m = StreakMonth(tx.date.year, tx.date.month);
              expenseByMonth[m] =
                  (expenseByMonth[m] ?? 0) + tx.amount.getOrCrash();
            }
          }

          // In-progress month status (on-track preview, R14)
          final currentMonthExpense = expenseByMonth[nowMonth] ?? 0;
          final isCurrentMonthOnTrack =
              totalBudget > 0 && currentMonthExpense <= totalBudget;

          // Zero budgets configured -> not qualifying (avoids free streak)
          final underBudgetConfig = StreakConfig(
            window: 1,
            minimum: minimum,
          );

          if (totalBudget <= 0 || transactions.isEmpty) {
            final result = _engine.calculate(
              qualifyingPeriods: const <StreakPeriod>{},
              today: lastCompletedMonth,
              config: underBudgetConfig,
              type: type,
            );
            return Right(
              result.current.copyWith(
                isCurrentMonthOnTrack: false,
              ),
            );
          }

          final earliestTx = transactions
              .map((tx) => tx.date)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          final earliestMonth =
              StreakMonth(earliestTx.year, earliestTx.month);

          final qualifyingMonths = <StreakPeriod>{};
          if (earliestMonth.compareTo(lastCompletedMonth) <= 0) {
            var m = earliestMonth;
            while (m.compareTo(lastCompletedMonth) <= 0) {
              final spent = expenseByMonth[m] ?? 0;
              if (spent <= totalBudget) {
                qualifyingMonths.add(m);
              }
              m = m.next();
            }
          }

          if (!qualifyingMonths.contains(lastCompletedMonth)) {
            final result = _engine.calculate(
              qualifyingPeriods: qualifyingMonths,
              today: lastCompletedMonth,
              config: underBudgetConfig,
              type: type,
            );
            return Right(
              Streak(
                type: type,
                length: 0,
                status: qualifyingMonths.isEmpty
                    ? StreakStatus.none
                    : StreakStatus.broken,
                daysUntilBreak: 0,
                nextMilestone: StreakEngine.resolveNextMilestone(0),
                consistencyRate: result.current.consistencyRate,
                bestLength: result.best.length,
                isCurrentMonthOnTrack: isCurrentMonthOnTrack,
              ),
            );
          }

          final result = _engine.calculate(
            qualifyingPeriods: qualifyingMonths,
            today: lastCompletedMonth,
            config: underBudgetConfig,
            type: type,
          );

          return Right(
            result.current.copyWith(
              isCurrentMonthOnTrack: isCurrentMonthOnTrack,
            ),
          );
      }
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StreakPeriod>>> getQualifyingPeriods({
    StreakType type = StreakType.tracking,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      switch (type) {
        case StreakType.tracking:
          final txResult = await _transactionRepository.getTransactions(
            startDate: startDate,
            endDate: endDate,
          );

          return txResult.fold(
            Left.new,
            (transactions) {
              final periods = transactions
                  .map((tx) => StreakDay.fromDateTime(tx.date))
                  .toSet()
                  .toList()
                ..sort();
              return Right(periods);
            },
          );

        case StreakType.noSpend:
          final txResult = await _transactionRepository.getTransactions(
            startDate: startDate,
            endDate: endDate,
          );

          return txResult.fold(
            Left.new,
            (transactions) {
              if (transactions.isEmpty && startDate == null) {
                return const Right(<StreakPeriod>[]);
              }

              final start = startDate ??
                  transactions
                      .map((tx) => tx.date)
                      .reduce((a, b) => a.isBefore(b) ? a : b);
              final end = endDate ?? DateTime.now();

              final startDay = StreakDay.fromDateTime(start);
              final endDay = StreakDay.fromDateTime(end);

              final expenseDays = transactions
                  .where((tx) => tx.type == TransactionType.expense)
                  .map((tx) => StreakDay.fromDateTime(tx.date))
                  .toSet();

              final periods = <StreakPeriod>[];
              var current =
                  DateTime(startDay.year, startDay.month, startDay.day);
              final target = DateTime(endDay.year, endDay.month, endDay.day);

              while (!current.isAfter(target)) {
                final day = StreakDay.fromDateTime(current);
                if (!expenseDays.contains(day)) {
                  periods.add(day);
                }
                current =
                    DateTime(current.year, current.month, current.day + 1);
              }

              periods.sort();
              return Right(periods);
            },
          );

        case StreakType.appOpen:
          final opensResult = await _appOpenRepository.getOpenDates(
            startDate: startDate,
            endDate: endDate,
          );

          return opensResult.fold(
            Left.new,
            (openDates) {
              final periods = openDates
                  .map(StreakDay.fromDateTime)
                  .toSet()
                  .toList()
                ..sort();
              return Right(periods);
            },
          );

        case StreakType.underBudget:
          final categoriesEither =
              await _categoryRepository.watchCategories().first;
          final txResult = await _transactionRepository.getTransactions(
            startDate: startDate,
            endDate: endDate,
          );

          final failure = categoriesEither.fold((f) => f, (_) => null) ??
              txResult.fold((f) => f, (_) => null);
          if (failure != null) {
            return Left(failure);
          }

          final allCategories =
              categoriesEither.getOrElse(() => const <Category>[]);
          final transactions =
              txResult.getOrElse(() => const <Transaction>[]);

          final totalBudget = CategoryBudgetCalculator.calculateTotalBudget(
            allCategories,
          );

          if (totalBudget <= 0) {
            return const Right(<StreakPeriod>[]);
          }

          final now = DateTime.now();
          final start = startDate ??
              (transactions.isNotEmpty
                  ? transactions
                      .map((tx) => tx.date)
                      .reduce((a, b) => a.isBefore(b) ? a : b)
                  : now);
          final end = endDate ?? now;

          final startMonth = StreakMonth(start.year, start.month);
          final endMonth = StreakMonth(end.year, end.month);

          final expenseByMonth = <StreakMonth, double>{};
          for (final tx in transactions) {
            if (tx.type == TransactionType.expense) {
              final m = StreakMonth(tx.date.year, tx.date.month);
              expenseByMonth[m] =
                  (expenseByMonth[m] ?? 0) + tx.amount.getOrCrash();
            }
          }

          final qualifyingMonths = <StreakPeriod>[];
          var m = startMonth;
          while (m.compareTo(endMonth) <= 0) {
            final spent = expenseByMonth[m] ?? 0;
            if (spent <= totalBudget) {
              qualifyingMonths.add(m);
            }
            m = m.next();
          }

          qualifyingMonths.sort();
          return Right(qualifyingMonths);
      }
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryOverrunFlag>>> getCategoryOverrunFlags({
    DateTime? month,
  }) async {
    try {
      final targetMonth = month ?? DateTime.now();
      final categoriesEither =
          await _categoryRepository.watchCategories().first;
      final startOfMonth = DateTime(targetMonth.year, targetMonth.month);
      final endOfMonth =
          DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

      final txResult = await _transactionRepository.getTransactions(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final failure = categoriesEither.fold((f) => f, (_) => null) ??
          txResult.fold((f) => f, (_) => null);
      if (failure != null) {
        return Left(failure);
      }

      final allCategories =
          categoriesEither.getOrElse(() => const <Category>[]);
      final transactions =
          txResult.getOrElse(() => const <Transaction>[]);

      final flags = CategoryBudgetCalculator.calculateOverrunFlags(
        allCategories: allCategories,
        transactions: transactions,
      );

      return Right(flags);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isCurrentMonthOnTrack({
    DateTime? referenceDate,
  }) async {
    try {
      final now = referenceDate ?? DateTime.now();
      final categoriesEither =
          await _categoryRepository.watchCategories().first;
      final startOfMonth = DateTime(now.year, now.month);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final txResult = await _transactionRepository.getTransactions(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final failure = categoriesEither.fold((f) => f, (_) => null) ??
          txResult.fold((f) => f, (_) => null);
      if (failure != null) {
        return Left(failure);
      }

      final allCategories =
          categoriesEither.getOrElse(() => const <Category>[]);
      final transactions =
          txResult.getOrElse(() => const <Transaction>[]);

      final totalBudget = CategoryBudgetCalculator.calculateTotalBudget(
        allCategories,
      );

      if (totalBudget <= 0) return const Right(false);

      final currentSpent = transactions
          .where((tx) => tx.type == TransactionType.expense)
          .fold<double>(0, (acc, tx) => acc + tx.amount.getOrCrash());

      return Right(currentSpent <= totalBudget);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UnderBudgetMonthStatus>> getUnderBudgetStatus({
    DateTime? month,
  }) async {
    try {
      final targetMonth = month ?? DateTime.now();
      final categoriesEither =
          await _categoryRepository.watchCategories().first;
      final startOfMonth = DateTime(targetMonth.year, targetMonth.month);
      final endOfMonth =
          DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

      final txResult = await _transactionRepository.getTransactions(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final failure = categoriesEither.fold((f) => f, (_) => null) ??
          txResult.fold((f) => f, (_) => null);
      if (failure != null) {
        return Left(failure);
      }

      final allCategories =
          categoriesEither.getOrElse(() => const <Category>[]);
      final transactions =
          txResult.getOrElse(() => const <Transaction>[]);

      final totalBudget = CategoryBudgetCalculator.calculateTotalBudget(
        allCategories,
      );

      final currentSpent = transactions
          .where((tx) => tx.type == TransactionType.expense)
          .fold<double>(0, (acc, tx) => acc + tx.amount.getOrCrash());

      final flags = CategoryBudgetCalculator.calculateOverrunFlags(
        allCategories: allCategories,
        transactions: transactions,
      );

      return Right(
        UnderBudgetMonthStatus(
          month: targetMonth,
          totalBudget: totalBudget,
          totalSpent: currentSpent,
          isOnTrack: totalBudget > 0 && currentSpent <= totalBudget,
          overrunFlags: flags,
        ),
      );
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}
