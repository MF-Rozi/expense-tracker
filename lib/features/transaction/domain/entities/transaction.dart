import 'package:equatable/equatable.dart';
import 'package:template/features/transaction/domain/entities/transaction_type.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.uuid,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryUuid,
    required this.type,
    this.note,
  });

  final UniqueId uuid;
  final Amount amount;
  final StringSingleLine description;
  final DateTime date;
  final UniqueId categoryUuid;
  final TransactionType type;
  final String? note;

  @override
  List<Object?> get props => [
        uuid,
        amount,
        description,
        date,
        categoryUuid,
        type,
        note,
      ];
}
