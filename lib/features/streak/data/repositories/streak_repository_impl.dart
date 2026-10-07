import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/app_open_repository.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:expense_tracker/features/streak/domain/services/streak_engine.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StreakRepository)
class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(
    this._transactionRepository,
    this._localStorage,
    this._appOpenRepository, {
    StreakEngine engine = const StreakEngine(),
  }) : _engine = engine;

  final TransactionRepository _transactionRepository;
  final LocalStorage _localStorage;
  final AppOpenRepository _appOpenRepository;
  final StreakEngine _engine;

  static const defaultLookbackYears = 2;

  @override
  Future<Either<Failure, Streak>> getStreak({
    StreakType type = StreakType.tracking,
    DateTime? referenceDate,
  }) async {
    try {
      if (type == StreakType.underBudget) {
        return Left(
          Failure.localFailure(
            message: 'Streak type $type is not supported yet.',
          ),
        );
      }

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
          return Left(
            Failure.localFailure(
              message: 'Streak type $type is not supported yet.',
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
      if (type == StreakType.underBudget) {
        return Left(
          Failure.localFailure(
            message: 'Streak type $type is not supported yet.',
          ),
        );
      }

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
          return Left(
            Failure.localFailure(
              message: 'Streak type $type is not supported yet.',
            ),
          );
      }
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}
