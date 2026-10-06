import 'package:isar_community/isar.dart';

part 'app_open_model.g.dart';

@collection
class AppOpenModel {
  AppOpenModel();

  factory AppOpenModel.create({
    required String uuid,
    required DateTime date,
  }) {
    return AppOpenModel()
      ..uuid = uuid
      ..date = date;
  }

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late DateTime date;
}
