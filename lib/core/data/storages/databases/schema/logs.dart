import 'package:drift/drift.dart';

class Logs extends Table {
  TextColumn get id => text()();
  TextColumn get action => text()();
  TextColumn get path => text()();
  TextColumn get params => text()();
  IntColumn get status => integer()();
  IntColumn get responseCode => integer().nullable()();
  TextColumn get responseMessage => text().nullable()();
  TextColumn get responseData => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorData => text().nullable()();
  TextColumn get nextExecutionId => text().nullable()();
  IntColumn get retry => integer().withDefault(const Constant(0))();

  @override
  Set<Column<String?>>? get primaryKey => {id};
}
