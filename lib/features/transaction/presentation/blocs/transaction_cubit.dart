import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/features/transaction/domain/entities/transaction.dart';
import 'package:template/features/transaction/domain/usecases/save_transaction_use_case.dart';
import 'package:template/features/transaction/presentation/blocs/transaction_state.dart';
import 'package:template/features/transaction/presentation/utils/expression_evaluator.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit(this._saveTransactionUseCase)
      : super(TransactionState(date: DateTime.now()));

  final SaveTransactionUseCase _saveTransactionUseCase;
  final ExpressionEvaluator _evaluator = const ExpressionEvaluator();

  void updateExpression(String key) {
    String current = state.rawExpression;

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
          }
           else {
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
    emit(state.copyWith(
      rawExpression: current,
      parsedAmount: parsed,
      status: TransactionFormStatus.initial,
    ));
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

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  Future<void> submitTransaction() async {
    if (state.selectedCategory == null) {
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
        errorMessage: 'Please select a category',
      ));
      return;
    }

    emit(state.copyWith(status: TransactionFormStatus.loading));

    final transaction = Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(state.parsedAmount),
      description: StringSingleLine(state.description),
      date: state.date ?? DateTime.now(),
      categoryUuid: state.selectedCategory!.uuid,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    final result = await _saveTransactionUseCase(transaction);

    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionFormStatus.failure,
        errorMessage: failure.toString(),
      )),
      (_) => emit(state.copyWith(status: TransactionFormStatus.success)),
    );
  }
}
