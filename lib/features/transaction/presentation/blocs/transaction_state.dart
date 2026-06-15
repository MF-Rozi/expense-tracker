import 'package:equatable/equatable.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/features/transaction/domain/entities/transaction_type.dart';

enum TransactionFormStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  const TransactionState({
    this.rawExpression = '0',
    this.parsedAmount = 0.0,
    this.selectedCategory,
    this.type = TransactionType.expense,
    this.description = '',
    this.date,
    this.status = TransactionFormStatus.initial,
    this.errorMessage,
  });

  final String rawExpression;
  final double parsedAmount;
  final Category? selectedCategory;
  final TransactionType type;
  final String description;
  final DateTime? date;
  final TransactionFormStatus status;
  final String? errorMessage;

  TransactionState copyWith({
    String? rawExpression,
    double? parsedAmount,
    Category? selectedCategory,
    TransactionType? type,
    String? description,
    DateTime? date,
    TransactionFormStatus? status,
    String? errorMessage,
  }) {
    return TransactionState(
      rawExpression: rawExpression ?? this.rawExpression,
      parsedAmount: parsedAmount ?? this.parsedAmount,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        rawExpression,
        parsedAmount,
        selectedCategory,
        type,
        description,
        date,
        status,
        errorMessage,
      ];
}
