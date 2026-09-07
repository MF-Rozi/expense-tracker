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
const _subId = '550e8400-e29b-41d4-a716-446655440006';
const _e1Id = '550e8400-e29b-41d4-a716-446655440007';
const _e2Id = '550e8400-e29b-41d4-a716-446655440008';

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
final _food = _makeCategory(uuid: _subId, name: 'Food', parentId: _p1Id);
final _coffee = _makeCategory(
  uuid: _e1Id,
  name: 'Coffee',
  parentId: _subId,
  budget: 120,
);
final _groceries = _makeCategory(
  uuid: _e2Id,
  name: 'Groceries',
  parentId: _subId,
  budget: 180,
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

    group('three-level hierarchy', () {
      final deepCategories = [
        ...allCategories,
        _food,
        _coffee,
        _groceries,
      ];

      testWidgets('renders level-3 envelopes inline under sub-parents',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnvelopeTreeListView(allCategories: deepCategories),
              ),
            ),
          ),
        );

        expect(find.text('Food'), findsOneWidget);
        expect(find.text('Coffee'), findsOneWidget);
        expect(find.text('Groceries'), findsOneWidget);
        // $300 appears as: Dining leaf budget, Lifestyle pillar aggregate,
        // and Food sub-parent aggregate (120 + 180).
        expect(find.text(r'$300'), findsNWidgets(3));
      });

      testWidgets('chevron tap toggles level-3 children without onChildTap',
          (tester) async {
        var childTaps = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnvelopeTreeListView(
                  allCategories: deepCategories,
                  onChildTap: (_) => childTaps++,
                ),
              ),
            ),
          ),
        );

        final foodRowChevron = find.descendant(
          of: find.ancestor(
            of: find.text('Food'),
            matching: find.byType(InkWell),
          ),
          matching: find.byIcon(Icons.keyboard_arrow_down),
        );

        await tester.tap(foodRowChevron);
        await tester.pumpAndSettle();
        expect(find.text('Coffee'), findsNothing);
        expect(find.text('Groceries'), findsNothing);
        expect(childTaps, 0);

        await tester.tap(foodRowChevron);
        await tester.pumpAndSettle();
        expect(find.text('Coffee'), findsOneWidget);
        expect(find.text('Groceries'), findsOneWidget);
        expect(childTaps, 0);
      });

      testWidgets('sub-parent row tap fires onChildTap for focused page',
          (tester) async {
        Category? tapped;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnvelopeTreeListView(
                  allCategories: deepCategories,
                  onChildTap: (c) => tapped = c,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();
        expect(tapped?.uuid.getOrCrash(), _subId);
      });

      testWidgets('onChildTap fires for leaf envelope rows', (tester) async {
        Category? tapped;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnvelopeTreeListView(
                  allCategories: deepCategories,
                  onChildTap: (c) => tapped = c,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Coffee'));
        await tester.pumpAndSettle();
        expect(tapped?.uuid.getOrCrash(), _e1Id);
      });

      testWidgets('onChildEdit fires from sub-parent edit button',
          (tester) async {
        Category? edited;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnvelopeTreeListView(
                  allCategories: deepCategories,
                  onChildEdit: (c) => edited = c,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();
        expect(edited?.uuid.getOrCrash(), _subId);
      });

      testWidgets('orphaned cycle data does not crash rendering',
          (tester) async {
        // In a single-parent model a parent cycle can only exist as an
        // orphan island (unreachable from any root). Rendering must still
        // not crash, and budget aggregation's depth cap guards against
        // unbounded recursion if such data is ever summed directly.
        final cyclicFood = _makeCategory(
          uuid: _subId,
          name: 'Food',
          parentId: _subId, // cycle: Food is its own ancestor
        );
        final cyclicCoffee = _makeCategory(
          uuid: _e1Id,
          name: 'Coffee',
          parentId: _subId,
          budget: 120,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EnvelopeTreeListView(
                  allCategories: [
                    _essential,
                    cyclicFood,
                    cyclicCoffee,
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Essential'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
