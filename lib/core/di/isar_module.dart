import 'package:expense_tracker/core/utils/constants.dart' as c;
import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/transaction/data/models/transaction_model.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

@module
abstract class IsarModule {
  @lazySingleton
  @preResolve
  @Environment(c.Environment.development)
  @Environment(c.Environment.staging)
  @Environment(c.Environment.production)
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [CategoryModelSchema, TransactionModelSchema],
      directory: dir.path,
    );
  }

  @lazySingleton
  @preResolve
  @test
  Future<Isar> get isarTest async => FakeIsar();
}

class FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
