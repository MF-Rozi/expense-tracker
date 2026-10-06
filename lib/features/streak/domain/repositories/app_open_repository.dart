import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/app_open.dart';

abstract class AppOpenRepository {
  Future<Either<Failure, Unit>> recordOpen({
    DateTime? date,
    String? uuid,
  });

  Future<Either<Failure, List<DateTime>>> getOpenDates({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<AppOpen>>> getAppOpens({
    DateTime? startDate,
    DateTime? endDate,
  });
}
