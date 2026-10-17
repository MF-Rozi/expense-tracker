import 'package:expense_tracker/features/streak/data/models/app_open_model.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

abstract class AppOpenLocalDataSource {
  Future<void> recordOpen({DateTime? date, String? uuid});
  Future<List<DateTime>> getOpenDates({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<AppOpenModel>> getAppOpens({
    DateTime? startDate,
    DateTime? endDate,
  });
}

@LazySingleton(as: AppOpenLocalDataSource)
class IsarAppOpenLocalDataSource implements AppOpenLocalDataSource {
  IsarAppOpenLocalDataSource(this._isar);

  final Isar _isar;

  @override
  Future<void> recordOpen({DateTime? date, String? uuid}) async {
    final model = AppOpenModel.create(
      uuid: uuid ?? const Uuid().v4(),
      date: date ?? DateTime.now(),
    );
    await _isar.writeTxn(() async {
      await _isar.appOpenModels.put(model);
    });
  }

  @override
  Future<List<DateTime>> getOpenDates({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final opens = await getAppOpens(
      startDate: startDate,
      endDate: endDate,
    );
    return opens.map((e) => e.date).toList();
  }

  @override
  Future<List<AppOpenModel>> getAppOpens({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _isar.appOpenModels
        .filter()
        .optional(
          startDate != null && endDate != null,
          (q) => q.dateBetween(startDate!, endDate!),
        )
        .optional(
          startDate != null && endDate == null,
          (q) => q.dateGreaterThan(startDate!, include: true),
        )
        .optional(
          startDate == null && endDate != null,
          (q) => q.dateLessThan(endDate!, include: true),
        )
        .sortByDate();

    return query.findAll();
  }
}
