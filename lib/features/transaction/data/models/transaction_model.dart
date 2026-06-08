import 'package:isar_community/isar.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/features/transaction/domain/entities/transaction_type.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  TransactionModel();

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel()
      ..uuid = entity.uuid.getOrCrash()
      ..amount = entity.amount.getOrCrash()
      ..description = entity.description.getOrCrash()
      ..date = entity.date
      ..categoryUuid = entity.categoryUuid.getOrCrash()
      ..type = entity.type
      ..note = entity.note;
  }

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late double amount;

  late String description;

  @Index()
  late DateTime date;

  @Index()
  late String categoryUuid;

  @enumerated
  late TransactionType type;

  String? note;

  Transaction toEntity() {
    return Transaction(
      uuid: UniqueId(uuid),
      amount: Amount(amount),
      description: StringSingleLine(description),
      date: date,
      categoryUuid: UniqueId(categoryUuid),
      type: type,
      note: note,
    );
  }
}
