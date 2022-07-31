import 'dart:io';
import 'package:drift/drift.dart';

import 'package:drift/native.dart';
import 'package:expense_tracker/core/data/storages/databases/schema/logs.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'expense_database.g.dart';

@DriftDatabase(tables: [Logs])
class ExpenseDatabase extends _$ExpenseDatabase {
  // we tell the database where to store the data with this constructor
  ExpenseDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
