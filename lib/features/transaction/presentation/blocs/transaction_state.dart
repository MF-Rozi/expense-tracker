import 'package:equatable/equatable.dart';
import 'package:template/features/category/domain/entities/category.dart';

enum TransactionFormStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  const TransactionState({
    this.rawExpression = '0',
    this.parsedAmount = 0.0,
    this.selectedCategory,
    this.description = '',
    this.date,
    this.status = TransactionFormStatus.initial,
    this.errorMessage,
  });

  final String rawExpression;
  final double parsedAmount;
  final Category? selectedCategory;
  final String description;
  final DateTime? date;
  final TransactionFormStatus status;
  final String? errorMessage;

  TransactionState copyWith({
    String? rawExpression,
    double? parsedAmount,
    Category? selectedCategory,
    String? description,
    DateTime? date,
    TransactionFormStatus? status,
    String? errorMessage,
  }) {
    return TransactionState(
      rawExpression: rawExpression ?? this.rawExpression,
      parsedAmount: parsedAmount ?? this.parsedAmount,
      selectedCategory: selectedCategory ?? this.selectedCategory,
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
        description,
        date,
        status,
        errorMessage,
      ];
}
