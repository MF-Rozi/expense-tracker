import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:expense_tracker/features/streak/domain/services/streak_engine.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StreakRepository)
class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(
    this._transactionRepository,
    this._localStorage, {
    StreakEngine engine = const StreakEngine(),
  }) : _engine = engine;

  final TransactionRepository _transactionRepository;
  final LocalStorage _localStorage;
  final StreakEngine _engine;

  static const defaultLookbackYears = 2;

  @override
  Future<Either<Failure, Streak>> getStreak({
    StreakType type = StreakType.tracking,
    DateTime? referenceDate,
  }) async {
    try {
      if (type != StreakType.tracking) {
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
      if (type != StreakType.tracking) {
        return Left(
          Failure.localFailure(
            message: 'Streak type $type is not supported yet.',
          ),
        );
      }

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
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}
