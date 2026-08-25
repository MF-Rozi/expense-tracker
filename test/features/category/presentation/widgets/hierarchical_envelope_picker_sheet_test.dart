import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/widgets/hierarchical_envelope_picker_sheet.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryCubit extends MockCubit<CategoryState>
    implements CategoryCubit {}

Category _makeCategory({
  required String uuid,
  required String name,
  CategoryType type = CategoryType.expense,
  String? parentId,
  double budget = 0,
  BehavioralModifier modifier = BehavioralModifier.active,
}) {
  return Category(
    uuid: UniqueId(uuid),
    name: StringSingleLine(name),
    isSynced: false,
    updatedAt: DateTime(2026),
    type: type,
    expectedMonthlyBudget: budget,
    behavioralModifier: modifier,
    parentId: parentId != null ? UniqueId(parentId) : null,
  );
}

void main() {
  late MockCategoryCubit mockCategoryCubit;

  const p1 = '550e8400-e29b-41d4-a716-446655440001';
  const sp1 = '550e8400-e29b-41d4-a716-446655440002';
  const e1 = '550e8400-e29b-41d4-a716-446655440003';
  const p2 = '550e8400-e29b-41d4-a716-446655440004';
  const sp2 = '550e8400-e29b-41d4-a716-446655440005';
  const inc1 = '550e8400-e29b-41d4-a716-446655440006';
  const incSub1 = '550e8400-e29b-41d4-a716-446655440007';

  final essentialPillar = _makeCategory(
    uuid: p1,
    name: 'Essential',
    type: CategoryType.expense,
    budget: 1500,
  );
  final housingSub = _makeCategory(
    uuid: sp1,
    name: 'Housing',
    type: CategoryType.expense,
    parentId: p1,
    budget: 1200,
  );
  final rentEnvelope = _makeCategory(
    uuid: e1,
    name: 'Rent & Mortgage',
    type: CategoryType.expense,
    parentId: sp1,
    budget: 1200,
  );

  final lifestylePillar = _makeCategory(
    uuid: p2,
    name: 'Lifestyle',
    type: CategoryType.expense,
    budget: 500,
  );
  final diningSub = _makeCategory(
    uuid: sp2,
    name: 'Dining',
    type: CategoryType.expense,
    parentId: p2,
    budget: 300,
  );

  final salaryPillar = _makeCategory(
    uuid: inc1,
    name: 'Salary & Revenue',
    type: CategoryType.income,
    budget: 5000,
  );
  final techJobSub = _makeCategory(
    uuid: incSub1,
    name: 'Tech Job',
    type: CategoryType.income,
    parentId: inc1,
    budget: 5000,
  );

  final allCategories = [
    essentialPillar,
    housingSub,
    rentEnvelope,
    lifestylePillar,
    diningSub,
    salaryPillar,
    techJobSub,
  ];

  setUp(() {
    mockCategoryCubit = MockCategoryCubit();
    when(() => mockCategoryCubit.state).thenReturn(
      CategoryState(
        allCategories: allCategories,
        navigationStack: const [],
        isLoading: false,
      ),
    );
  });

  Widget buildTestWidget({
    required CategoryType targetType,
    Category? selectedCategory,
    required ValueChanged<Category> onSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CategoryCubit>.value(
          value: mockCategoryCubit,
          child: HierarchicalEnvelopePickerSheet(
            targetType: targetType,
            selectedCategory: selectedCategory,
            onCategorySelected: onSelected,
          ),
        ),
      ),
    );
  }

  testWidgets('renders expense pillars and hides income categories',
      (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        targetType: CategoryType.expense,
        onSelected: (_) {},
      ),
    );

    expect(find.text('Select Envelope'), findsOneWidget);
    expect(find.text('EXPENSE ENVELOPES'), findsOneWidget);
    expect(find.text('Essential'), findsOneWidget);
    expect(find.text('Lifestyle'), findsOneWidget);
    expect(find.text('Housing'), findsOneWidget);
    expect(find.text('Dining'), findsOneWidget);

    // Income categories should NOT appear
    expect(find.text('Salary & Revenue'), findsNothing);
    expect(find.text('Tech Job'), findsNothing);
  });

  testWidgets('renders income pillars when targetType is income',
      (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        targetType: CategoryType.income,
        onSelected: (_) {},
      ),
    );

    expect(find.text('INCOME ENVELOPES'), findsOneWidget);
    expect(find.text('Salary & Revenue'), findsOneWidget);
    expect(find.text('Tech Job'), findsOneWidget);

    // Expense categories should NOT appear
    expect(find.text('Essential'), findsNothing);
    expect(find.text('Lifestyle'), findsNothing);
  });

  testWidgets('tapping an envelope triggers onCategorySelected callback',
      (tester) async {
    Category? selected;
    await tester.pumpWidget(
      buildTestWidget(
        targetType: CategoryType.expense,
        onSelected: (cat) => selected = cat,
      ),
    );

    // Tap on Housing
    await tester.tap(find.text('Housing'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.name.getOrCrash(), 'Housing');
  });

  testWidgets('collapsing pillar hides its child envelopes', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        targetType: CategoryType.expense,
        onSelected: (_) {},
      ),
    );

    expect(find.text('Housing'), findsOneWidget);

    // Tap Essential pillar header to collapse
    await tester.tap(find.text('Essential'));
    await tester.pumpAndSettle();

    expect(find.text('Housing'), findsNothing);

    // Tap Essential pillar header again to expand
    await tester.tap(find.text('Essential'));
    await tester.pumpAndSettle();

    expect(find.text('Housing'), findsOneWidget);
  });

  testWidgets('searching filters envelopes and displays breadcrumb path',
      (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        targetType: CategoryType.expense,
        onSelected: (_) {},
      ),
    );

    // Enter search query
    await tester.enterText(find.byType(TextField), 'Rent');
    await tester.pumpAndSettle();

    expect(find.text('Rent & Mortgage'), findsOneWidget);
    expect(find.text('Essential › Housing › Rent & Mortgage'), findsOneWidget);

    // Dining should be filtered out
    expect(find.text('Dining'), findsNothing);
  });

  testWidgets('shows empty state when no categories match target type',
      (tester) async {
    when(() => mockCategoryCubit.state).thenReturn(
      CategoryState.initial(),
    );

    await tester.pumpWidget(
      buildTestWidget(
        targetType: CategoryType.expense,
        onSelected: (_) {},
      ),
    );

    expect(find.text('No Expense Envelopes'), findsOneWidget);
    expect(find.text('Create First Envelope'), findsOneWidget);
  });
}
