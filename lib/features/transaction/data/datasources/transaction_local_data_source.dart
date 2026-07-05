import 'package:expense_tracker/features/transaction/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';

abstract class TransactionLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();
  Future<void> saveTransaction(TransactionModel transaction);
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
        .watch(fireImmediately: true);
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(transaction);
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
    var query = _isar.transactionModels.filter();

    if (startDate != null && endDate != null) {
      query = query.dateBetween(startDate, endDate)
          as QueryBuilder<TransactionModel, TransactionModel, QFilterCondition>;
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.group(
        (q) => q
            .descriptionContains(searchQuery, caseSensitive: false)
            .or()
            .noteContains(searchQuery, caseSensitive: false),
      ) as QueryBuilder<TransactionModel, TransactionModel, QFilterCondition>;
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.categoryUuidEqualTo(categoryId)
          as QueryBuilder<TransactionModel, TransactionModel, QFilterCondition>;
    }

    if (flowType != 'all') {
      final type = TransactionType.values.firstWhere(
        (e) => e.name == flowType,
      );
      query = query.typeEqualTo(type)
          as QueryBuilder<TransactionModel, TransactionModel, QFilterCondition>;
    }

    final sortQuery =
        query as QueryBuilder<TransactionModel, TransactionModel, QSortBy>;
    return sortQuery.sortByDateDesc().findAll();
  }
}
