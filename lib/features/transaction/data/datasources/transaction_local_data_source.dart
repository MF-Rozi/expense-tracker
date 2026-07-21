import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/transaction/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';

abstract class TransactionLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();
  Future<void> saveTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String uuid);
  Future<List<TransactionModel>> getTransactions({
    required String flowType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? categoryId,
  });
}

@LazySingleton(as: TransactionLocalDataSource)
class IsarTransactionLocalDataSource implements TransactionLocalDataSource {
  IsarTransactionLocalDataSource(this._isar);

  final Isar _isar;

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return _isar.transactionModels
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .asyncMap((list) async {
      for (final t in list) {
        await t.category.load();
      }
      return list;
    });
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      final categoryModel = await _isar.categoryModels
          .filter()
          .uuidEqualTo(transaction.categoryUuid)
          .findFirst();
      if (categoryModel != null) {
        transaction.category.value = categoryModel;
      }
      await _isar.transactionModels.put(transaction);
      await transaction.category.save();
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.transactionModels
          .filter()
          .uuidEqualTo(transaction.uuid)
          .findFirst();
      if (existing != null) {
        transaction.id = existing.id;
      }
      final categoryModel = await _isar.categoryModels
          .filter()
          .uuidEqualTo(transaction.categoryUuid)
          .findFirst();
      if (categoryModel != null) {
        transaction.category.value = categoryModel;
      }
      await _isar.transactionModels.put(transaction);
      await transaction.category.save();
    });
  }

  @override
  Future<void> deleteTransaction(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.filter().uuidEqualTo(uuid).deleteAll();
    });
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    required String flowType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? categoryId,
  }) async {
    final list = await _isar.transactionModels
        .filter()
        .optional(
          startDate != null && endDate != null,
          (q) => q.dateBetween(startDate!, endDate!),
        )
        .optional(
          searchQuery != null && searchQuery.isNotEmpty,
          (q) => q.group(
            (q2) => q2
                .descriptionContains(searchQuery!, caseSensitive: false)
                .or()
                .noteContains(searchQuery, caseSensitive: false),
          ),
        )
        .optional(
          categoryId != null && categoryId.isNotEmpty,
          (q) => q.categoryUuidEqualTo(categoryId!),
        )
        .optional(
          flowType != 'all',
          (q) {
            final type = TransactionType.values.firstWhere(
              (e) => e.name == flowType,
            );
            return q.typeEqualTo(type);
          },
        )
        .sortByDateDesc()
        .findAll();

    for (final t in list) {
      await t.category.load();
    }
    return list;
  }
}
