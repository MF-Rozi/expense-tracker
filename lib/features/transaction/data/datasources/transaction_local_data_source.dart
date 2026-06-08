import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:template/features/transaction/data/models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();
  Future<void> saveTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String uuid);
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
}
