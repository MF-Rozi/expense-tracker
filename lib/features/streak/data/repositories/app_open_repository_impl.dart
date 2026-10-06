import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/data/datasources/app_open_local_data_source.dart';
import 'package:expense_tracker/features/streak/domain/entities/app_open.dart';
import 'package:expense_tracker/features/streak/domain/repositories/app_open_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AppOpenRepository)
class AppOpenRepositoryImpl implements AppOpenRepository {
  AppOpenRepositoryImpl(this._localDataSource);

  final AppOpenLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, Unit>> recordOpen({
    DateTime? date,
    String? uuid,
  }) async {
    try {
      await _localDataSource.recordOpen(date: date, uuid: uuid);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getOpenDates({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dates = await _localDataSource.getOpenDates(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(dates);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppOpen>>> getAppOpens({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _localDataSource.getAppOpens(
        startDate: startDate,
        endDate: endDate,
      );
      final entities = models
          .map((m) => AppOpen(uuid: m.uuid, date: m.date))
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}
