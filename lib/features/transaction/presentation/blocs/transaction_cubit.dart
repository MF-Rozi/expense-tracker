import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/create_transaction_use_case.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/update_transaction_use_case.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_state.dart';
import 'package:expense_tracker/features/transaction/presentation/utils/expression_evaluator.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit(
    this._createTransactionUseCase,
    this._updateTransactionUseCase,
  ) : super(TransactionState(date: DateTime.now()));

  final CreateTransactionUseCase _createTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final ExpressionEvaluator _evaluator = const ExpressionEvaluator();

  void updateExpression(String key) {
    var current = state.rawExpression;

    if (key == 'BACKSPACE') {
      if (current.length <= 1) {
        current = '0';
      } else {
        current = current.substring(0, current.length - 1);
      }
    } else if (key == 'C') {
      current = '0';
    } else if (key == '00') {
      if (current == '0') return;
      current += '00';
    } else {
      // Handle operators and decimals
      if (_isOperator(key)) {
        if (current.isEmpty || _isOperator(current[current.length - 1])) {
          // Replace last operator or don't allow starting with operator
          if (current.isNotEmpty) {
            current = current.substring(0, current.length - 1) + key;
          } else if (key == '-') {
            current = key;
          } else {
            return;
          }
        } else {
          current += key;
        }
      } else {
        if (current == '0' && key != '.') {
          current = key;
        } else {
          current += key;
        }
      }
    }

    final parsed = _evaluator.evaluate(current);
    emit(
      state.copyWith(
        rawExpression: current,
        parsedAmount: parsed,
        status: TransactionFormStatus.initial,
      ),
    );
  }

  bool _isOperator(String char) {
    return ['+', '-', 'x', '÷', '*', '/'].contains(char);
  }

  void selectCategory(Category category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void updateType(TransactionType type) {
    final currentCat = state.selectedCategory;
    final isMismatch = currentCat != null &&
        ((type == TransactionType.expense &&
                currentCat.type != CategoryType.expense) ||
            (type == TransactionType.income &&
                currentCat.type != CategoryType.income));

    emit(
      state.copyWith(
        type: type,
        clearSelectedCategory: isMismatch,
      ),
    );
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void updateNote(String note) {
    emit(state.copyWith(note: note));
  }

  void loadExistingTransaction(Transaction transaction, Category? category) {
    // Format amount with no decimal digits if it is a whole number,
    // otherwise show decimals.
    final amount = transaction.amount.getOrCrash();
    final rawExpr = amount == amount.toInt()
        ? amount.toInt().toString()
        : amount.toString();

    emit(
      state.copyWith(
        existingTransactionId: transaction.uuid,
        rawExpression: rawExpr,
        parsedAmount: amount,
        selectedCategory: category,
        type: transaction.type,
        description: transaction.description.getOrCrash(),
        date: transaction.date,
        status: TransactionFormStatus.initial,
        note: transaction.note ?? '',
      ),
    );
  }

  Future<void> submitTransaction() async {
    if (state.selectedCategory == null) {
      emit(
        state.copyWith(
          status: TransactionFormStatus.failure,
          errorMessage: 'Please select a category',
        ),
      );
      return;
    }

    emit(state.copyWith(status: TransactionFormStatus.loading));

    final transaction = Transaction(
      uuid: state.existingTransactionId ?? UniqueId.generate(),
      amount: Amount(state.parsedAmount),
      description: StringSingleLine(state.description),
      date: state.date ?? DateTime.now(),
      categoryUuid: state.selectedCategory!.uuid,
      type: state.type,
      note: state.note.isNotEmpty ? state.note : null,
    );

    final result = state.existingTransactionId != null
        ? await _updateTransactionUseCase(transaction)
        : await _createTransactionUseCase(transaction);

    final newState = result.fold(
      (failure) => state.copyWith(
        status: TransactionFormStatus.failure,
        errorMessage: failure.message,
      ),
      (_) => state.copyWith(status: TransactionFormStatus.success),
    );
    emit(newState);
  }
}
