import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/presentation/widgets/transaction_card.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/helpers.dart';

class MockCategoryCubit extends MockCubit<CategoryState>
    implements CategoryCubit {}

void main() {
  late MockCategoryCubit categoryCubit;
  late StreamController<CategoryState> categoriesController;

  final uncategorized = Transaction(
    uuid: UniqueId.generate(),
    amount: Amount(99000),
    description: StringSingleLine('Snack'),
    date: DateTime(2026),
    categoryUuid: UniqueId('550e8400-e29b-41d4-a716-446655440001'),
    type: TransactionType.expense,
  );

  final groceries = Category(
    uuid: UniqueId('550e8400-e29b-41d4-a716-446655440001'),
    name: StringSingleLine('Groceries & Household'),
    isSynced: false,
    updatedAt: DateTime(2026),
    type: CategoryType.expense,
    expectedMonthlyBudget: 0,
    behavioralModifier: BehavioralModifier.active,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    categoryCubit = MockCategoryCubit();
    categoriesController = StreamController<CategoryState>();
    whenListen(
      categoryCubit,
      categoriesController.stream,
      initialState: CategoryState.initial(),
    );
  });

  tearDown(() async {
    await categoriesController.close();
  });

  testWidgets('falls back to Uncategorized before categories load',
      (tester) async {
    await tester.pumpApp(
      BlocProvider<CategoryCubit>.value(
        value: categoryCubit,
        child: TransactionCard(transaction: uncategorized),
      ),
    );

    expect(find.textContaining('Uncategorized'), findsOneWidget);
    expect(find.textContaining('Groceries'), findsNothing);
  });

  testWidgets('resolves the category once the stream emits it',
      (tester) async {
    await tester.pumpApp(
      BlocProvider<CategoryCubit>.value(
        value: categoryCubit,
        child: TransactionCard(transaction: uncategorized),
      ),
    );
    expect(find.textContaining('Uncategorized'), findsOneWidget);

    // First-launch race: the categories stream emits after the card has
    // already rendered with the empty fallback.
    categoriesController.add(
      CategoryState.initial().copyWith(allCategories: [groceries]),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Groceries & Household'), findsOneWidget);
    expect(find.textContaining('Uncategorized'), findsNothing);
  });
}
