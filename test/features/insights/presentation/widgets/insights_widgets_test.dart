import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/envelope_drill_down_list.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/insights_hero_card.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/pillar_distribution_chart.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/timeframe_filter_row.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Fixtures ───────────────────────────────────────────────────────────────

const pillarUuid = '11111111-1111-4111-8111-111111111111';
const groceriesUuid = '33333333-3333-4333-8333-333333333333';
const lifestyleUuid = '44444444-4444-4444-8444-444444444444';
const salaryUuid = '55555555-5555-4555-8555-555555555555';

Category _category({
  required String uuid,
  required String name,
  required CategoryType type,
  String? parentId,
}) {
  return Category(
    uuid: UniqueId(uuid),
    name: StringSingleLine(name),
    isSynced: false,
    updatedAt: DateTime(2026),
    type: type,
    expectedMonthlyBudget: 0,
    behavioralModifier: BehavioralModifier.active,
    parentId: parentId != null ? UniqueId(parentId) : null,
  );
}

final _essential = _category(
  uuid: pillarUuid,
  name: 'Essential',
  type: CategoryType.expense,
);
final _groceries = _category(
  uuid: groceriesUuid,
  name: 'Groceries',
  type: CategoryType.expense,
  parentId: pillarUuid,
);
final _lifestyle = _category(
  uuid: lifestyleUuid,
  name: 'Lifestyle',
  type: CategoryType.expense,
);
final _salary = _category(
  uuid: salaryUuid,
  name: 'Salary',
  type: CategoryType.income,
);

PillarInsight _pillar(
  Category pillar, {
  required double outflow,
  required double inflow,
  required double shareOfTotalOutflow,
  required List<EnvelopeInsight> envelopes,
}) {
  return PillarInsight(
    pillar: pillar,
    outflow: outflow,
    inflow: inflow,
    shareOfTotalOutflow: shareOfTotalOutflow,
    envelopes: envelopes,
  );
}

EnvelopeInsight _envelope(
  Category category, {
  required double outflow,
  required double inflow,
  required int transactionCount,
  required double shareOfPillar,
}) {
  return EnvelopeInsight(
    category: category,
    breadcrumb: category
        .getBreadcrumbPath([_essential, _groceries, _lifestyle, _salary]),
    outflow: outflow,
    inflow: inflow,
    transactionCount: transactionCount,
    shareOfPillar: shareOfPillar,
  );
}

final _summary = InsightsSummary(
  totalOutflow: 800,
  totalInflow: 700,
  outflowDelta: InsightsDelta.calculate(current: 800, previous: 200),
  inflowDelta: InsightsDelta.calculate(current: 700, previous: 500),
  pillars: [
    _pillar(
      _essential,
      outflow: 600,
      inflow: 0,
      shareOfTotalOutflow: 0.75,
      envelopes: [
        _envelope(
          _groceries,
          outflow: 400,
          inflow: 0,
          transactionCount: 2,
          shareOfPillar: 2 / 3,
        ),
        _envelope(
          _essential,
          outflow: 200,
          inflow: 0,
          transactionCount: 1,
          shareOfPillar: 1 / 3,
        ),
      ],
    ),
    _pillar(
      _lifestyle,
      outflow: 200,
      inflow: 0,
      shareOfTotalOutflow: 0.25,
      envelopes: [
        _envelope(
          _lifestyle,
          outflow: 200,
          inflow: 0,
          transactionCount: 1,
          shareOfPillar: 1,
        ),
      ],
    ),
    _pillar(
      _salary,
      outflow: 0,
      inflow: 700,
      shareOfTotalOutflow: 0,
      envelopes: [
        _envelope(
          _salary,
          outflow: 0,
          inflow: 700,
          transactionCount: 1,
          shareOfPillar: 1,
        ),
      ],
    ),
  ],
);

const _emptySummary = InsightsSummary(
  totalOutflow: 0,
  totalInflow: 0,
  outflowDelta: InsightsDelta(current: 0, previous: 0, isNew: false),
  inflowDelta: InsightsDelta(current: 0, previous: 0, isNew: false),
  pillars: [],
);

// Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('TimeframeFilterRow', () {
    testWidgets('renders the three timeframe labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeframeFilterRow(
              selected: InsightsTimeframe.thisMonth,
              onTimeframeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Quarter'), findsOneWidget);
      expect(find.text('YTD'), findsOneWidget);
    });

    testWidgets('fires onTimeframeChanged when a segment is tapped',
        (tester) async {
      InsightsTimeframe? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeframeFilterRow(
              selected: InsightsTimeframe.thisMonth,
              onTimeframeChanged: (t) => tapped = t,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Last Quarter'));
      expect(tapped, InsightsTimeframe.lastQuarter);
    });
  });

  group('InsightsHeroCard', () {
    testWidgets('renders formatted totals and a positive outflow delta',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: InsightsHeroCard(summary: _summary))),
      );

      expect(find.text('TOTAL OUTFLOW'), findsOneWidget);
      expect(find.text('IDR 800'), findsOneWidget);
      expect(find.text('IDR 700'), findsOneWidget);
      // Outflow increased -> red ▲ chip; inflow increased -> green ▲.
      expect(find.text('▲ 300%'), findsOneWidget);
      expect(find.text('▲ 40%'), findsOneWidget);
    });

    testWidgets('shows NEW chip when the previous window was silent',
        (tester) async {
      const newSummary = InsightsSummary(
        totalOutflow: 50,
        totalInflow: 0,
        outflowDelta: InsightsDelta(current: 50, previous: 0, isNew: true),
        inflowDelta: InsightsDelta(
          current: 0,
          previous: 0,
          isNew: false,
        ),
        pillars: [],
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InsightsHeroCard(summary: newSummary)),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('—'), findsOneWidget); // silent inflow
    });
  });

  group('PillarDistributionChart', () {
    testWidgets('splits the bar by outflow share and renders the legend',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PillarDistributionChart(summary: _summary),
          ),
        ),
      );

      // Income pillar takes no bar segment.
      expect(find.byKey(const ValueKey('pillar_segment_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('pillar_segment_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pillar_segment_2')), findsNothing);

      // Legend: expense pillars with amounts and shares.
      expect(find.text('Essential'), findsOneWidget);
      expect(find.text('Lifestyle'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget); // 600/800
      expect(find.text('25%'), findsOneWidget); // 200/800
      expect(find.text('IDR 600'), findsOneWidget);
      expect(find.text('IDR 200'), findsOneWidget);
      expect(find.text('Salary'), findsNothing); // no outflow share
    });

    testWidgets('renders a muted track when there is no outflow',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PillarDistributionChart(summary: _emptySummary),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('pillar_segment_0')), findsNothing);
      expect(find.byType(Row), findsNothing);
    });
  });

  group('EnvelopeDrillDownList', () {
    testWidgets('renders pillar sections with breadcrumbs and amounts',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnvelopeDrillDownList(pillars: _summary.pillars),
          ),
        ),
      );

      expect(find.text('ESSENTIAL'), findsOneWidget);
      expect(find.text('LIFESTYLE'), findsOneWidget);
      expect(find.text('SALARY'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(
        find.text('Essential › Groceries'),
        findsOneWidget,
      );
      expect(find.text('IDR 400'), findsOneWidget); // groceries amount
      expect(find.text('IDR 700'), findsNWidgets(2)); // salary header + row
    });

    testWidgets('omits pillars without activity', (tester) async {
      final withSilentPillar = InsightsSummary(
        totalOutflow: 0,
        totalInflow: 0,
        outflowDelta: const InsightsDelta(
          current: 0,
          previous: 0,
          isNew: false,
        ),
        inflowDelta: const InsightsDelta(
          current: 0,
          previous: 0,
          isNew: false,
        ),
        pillars: [
          _pillar(
            _lifestyle,
            outflow: 0,
            inflow: 0,
            shareOfTotalOutflow: 0,
            envelopes: const [],
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnvelopeDrillDownList(pillars: withSilentPillar.pillars),
          ),
        ),
      );

      expect(find.text('LIFESTYLE'), findsNothing);
    });
  });
}
