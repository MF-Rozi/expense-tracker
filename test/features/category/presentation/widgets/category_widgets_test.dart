import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/widgets/envelope_creation_form.dart';
import 'package:expense_tracker/features/category/presentation/widgets/envelope_tree_list_view.dart';
import 'package:expense_tracker/features/category/presentation/widgets/hierarchy_insight_card.dart';
import 'package:expense_tracker/features/category/presentation/widgets/portfolio_distribution_card.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Helpers ───────────────────────────────────────────────────────────────────

Category _makeCategory({
  required String uuid,
  required String name,
  String? parentId,
  double budget = 0,
  BehavioralModifier modifier = BehavioralModifier.active,
}) {
  return Category(
    uuid: UniqueId(uuid),
    name: StringSingleLine(name),
    isSynced: false,
    updatedAt: DateTime(2026),
    type: CategoryType.expense,
    expectedMonthlyBudget: budget,
    behavioralModifier: modifier,
    parentId: parentId != null ? UniqueId(parentId) : null,
  );
}

const _p1Id = '550e8400-e29b-41d4-a716-446655440001';
const _p2Id = '550e8400-e29b-41d4-a716-446655440002';
const _p3Id = '550e8400-e29b-41d4-a716-446655440003';
const _c1Id = '550e8400-e29b-41d4-a716-446655440004';
const _c2Id = '550e8400-e29b-41d4-a716-446655440005';

final _essential = _makeCategory(uuid: _p1Id, name: 'Essential');
final _lifestyle = _makeCategory(uuid: _p2Id, name: 'Lifestyle');
final _growth = _makeCategory(uuid: _p3Id, name: 'Growth');
final _mortgage = _makeCategory(
  uuid: _c1Id,
  name: 'Mortgage & Rent',
  parentId: _p1Id,
  budget: 1200,
);
final _dining = _makeCategory(
  uuid: _c2Id,
  name: 'Dining',
  parentId: _p2Id,
  budget: 300,
);

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── PortfolioDistributionCard ─────────────────────────────────────────────
  group('PortfolioDistributionCard', () {
    testWidgets('renders total budget amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioDistributionCard(
              pillars: [_essential, _lifestyle, _growth],
              pillarBudgets: const {_p1Id: 1200, _p2Id: 300, _p3Id: 0},
              totalBudget: 1500,
            ),
          ),
        ),
      );

      expect(find.text(r'$1500.00'), findsOneWidget);
    });

    testWidgets('shows "Portfolio Distribution" label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioDistributionCard(
              pillars: [_essential],
              pillarBudgets: const {_p1Id: 500},
              totalBudget: 500,
            ),
          ),
        ),
      );

      expect(find.textContaining('Portfolio Distribution'), findsOneWidget);
    });

    testWidgets('renders without pillars (empty state)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PortfolioDistributionCard(
              pillars: [],
              pillarBudgets: {},
              totalBudget: 0,
            ),
          ),
        ),
      );

      // No crash; label is still present
      expect(find.textContaining('Portfolio Distribution'), findsOneWidget);
    });
  });

  // ── HierarchyInsightCard ─────────────────────────────────────────────────
  group('HierarchyInsightCard', () {
    testWidgets('shows hierarchy path in bold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchyInsightCard(
              envelopeName: 'Artisanal Coffee',
              pillar: _lifestyle,
              subParent: _dining,
              totalBudget: 1500,
              envelopeBudget: 120,
            ),
          ),
        ),
      );

      expect(find.text('Hierarchy Insight'), findsOneWidget);
      expect(
        find.textContaining('Artisanal Coffee', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Lifestyle > Dining', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('shows percentage when budget is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchyInsightCard(
              envelopeName: 'Coffee',
              pillar: _lifestyle,
              subParent: _dining,
              totalBudget: 1000,
              envelopeBudget: 100, // 10%
            ),
          ),
        ),
      );

      expect(find.textContaining('10%', findRichText: true), findsOneWidget);
    });

    testWidgets('handles null pillar/subParent gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HierarchyInsightCard(
              envelopeName: '',
              pillar: null,
              subParent: null,
              totalBudget: 0,
              envelopeBudget: 0,
            ),
          ),
        ),
      );

      // Uses em-dashes for missing pillars
      expect(find.textContaining('—', findRichText: true), findsWidgets);
    });
  });

  // ── EnvelopeCreationForm ─────────────────────────────────────────────────
  group('EnvelopeCreationForm', () {
    late TextEditingController nameCtrl;
    late TextEditingController budgetCtrl;

    setUp(() {
      nameCtrl = TextEditingController();
      budgetCtrl = TextEditingController();
    });

    tearDown(() {
      nameCtrl.dispose();
      budgetCtrl.dispose();
    });

    testWidgets('renders Expense / Income toggles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvelopeCreationForm(
                selectedType: CategoryType.expense,
                availablePillars: [_essential, _lifestyle, _growth],
                selectedPillar: null,
                selectedModifier: BehavioralModifier.active,
                nameController: nameCtrl,
                budgetController: budgetCtrl,
                onTypeChanged: (_) {},
                onPillarChanged: (_) {},
                onModifierChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('fires onTypeChanged when Income tapped', (tester) async {
      CategoryType? received;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvelopeCreationForm(
                selectedType: CategoryType.expense,
                availablePillars: [_essential, _lifestyle, _growth],
                selectedPillar: null,
                selectedModifier: BehavioralModifier.active,
                nameController: nameCtrl,
                budgetController: budgetCtrl,
                onTypeChanged: (t) => received = t,
                onPillarChanged: (_) {},
                onModifierChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Income'));
      expect(received, CategoryType.income);
    });

    testWidgets('renders modifier pills', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvelopeCreationForm(
                selectedType: CategoryType.expense,
                availablePillars: const [],
                selectedPillar: null,
                selectedModifier: BehavioralModifier.passive,
                nameController: nameCtrl,
                budgetController: budgetCtrl,
                onTypeChanged: (_) {},
                onPillarChanged: (_) {},
                onModifierChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('PASSIVE'), findsOneWidget);
      expect(find.text('RECURRING'), findsOneWidget);
    });
  });

  // ── EnvelopeTreeListView ─────────────────────────────────────────────────
  group('EnvelopeTreeListView', () {
    final allCategories = [
      _essential,
      _lifestyle,
      _growth,
      _mortgage,
      _dining,
    ];

    testWidgets('renders pillar names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvelopeTreeListView(allCategories: allCategories),
            ),
          ),
        ),
      );

      expect(find.text('Essential'), findsOneWidget);
      expect(find.text('Lifestyle'), findsOneWidget);
      expect(find.text('Growth'), findsOneWidget);
    });

    testWidgets('renders child categories under pillars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvelopeTreeListView(allCategories: allCategories),
            ),
          ),
        ),
      );

      expect(find.text('Mortgage & Rent'), findsOneWidget);
      expect(find.text('Dining'), findsOneWidget);
    });

    testWidgets('collapses pillar section on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnvelopeTreeListView(allCategories: allCategories),
            ),
          ),
        ),
      );

      // Mortgage is visible before collapse
      expect(find.text('Mortgage & Rent'), findsOneWidget);

      // Tap Essential pillar header to collapse
      await tester.tap(find.text('Essential'));
      await tester.pumpAndSettle();

      expect(find.text('Mortgage & Rent'), findsNothing);
    });

    testWidgets('shows empty state when no categories', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnvelopeTreeListView(allCategories: []),
          ),
        ),
      );

      expect(find.textContaining('No envelopes yet'), findsOneWidget);
    });
  });
}
