import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:expense_tracker/features/insights/domain/usecases/get_insights_summary_usecase.dart';
import 'package:expense_tracker/features/insights/presentation/blocs/insights_cubit.dart';
import 'package:expense_tracker/features/insights/presentation/pages/insights_page.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:expense_tracker/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/helpers.dart';

class MockGetInsightsSummaryUseCase extends Mock
    implements GetInsightsSummaryUseCase {}

void main() {
  late MockGetInsightsSummaryUseCase useCase;

  final fixedNow = DateTime(2026, 9, 15, 10);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureInjector();
    registerFallbackValue(
      GetInsightsSummaryParams(
        timeframe: InsightsTimeframe.thisMonth,
        now: DateTime(2026, 9, 15, 10),
      ),
    );
  });

  final essential = _category(
    uuid: '11111111-1111-4111-8111-111111111111',
    name: 'Essential',
    type: CategoryType.expense,
  );
  final groceries = _category(
    uuid: '33333333-3333-4333-8333-333333333333',
    name: 'Groceries',
    type: CategoryType.expense,
    parentId: '11111111-1111-4111-8111-111111111111',
  );

  final summary = InsightsSummary(
    totalOutflow: 600,
    totalInflow: 250,
    outflowDelta: InsightsDelta.calculate(current: 600, previous: 500),
    inflowDelta: InsightsDelta.calculate(current: 250, previous: 300),
    pillars: [
      PillarInsight(
        pillar: essential,
        outflow: 600,
        inflow: 0,
        shareOfTotalOutflow: 1,
        envelopes: [
          EnvelopeInsight(
            category: groceries,
            breadcrumb: 'Essential › Groceries',
            outflow: 600,
            inflow: 0,
            transactionCount: 3,
            shareOfPillar: 1,
          ),
        ],
      ),
    ],
  );

  setUp(() {
    useCase = MockGetInsightsSummaryUseCase();
  });

  /// Pumps the page with an injected cubit plus the app-root FlashCubit
  /// provider (the failure listener flashes through it).
  Future<void> pumpPage(WidgetTester tester, InsightsCubit cubit) {
    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<InsightsCubit>.value(value: cubit),
          BlocProvider<FlashCubit>(create: (_) => FlashCubit()),
        ],
        child: MaterialApp(home: InsightsPage(insightsCubit: cubit)),
      ),
    );
  }

  testWidgets('renders hero, chart, and drill-down after load', (tester) async {
    when(() => useCase.call(any())).thenAnswer(
      (_) async => Right(summary),
    );
    final cubit = InsightsCubit(useCase, nowProvider: () => fixedNow);

    await pumpPage(tester, cubit);
    await tester.pumpAndSettle();

    expect(find.text('TOTAL OUTFLOW'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Where Your Money Went'), findsOneWidget);
    expect(find.text('ESSENTIAL'), findsOneWidget);
    expect(find.text('Essential › Groceries'), findsOneWidget);
  });

  testWidgets('tapping a timeframe refetches with new params', (tester) async {
    when(() => useCase.call(any())).thenAnswer(
      (_) async => const Right(
        InsightsSummary(
          totalOutflow: 0,
          totalInflow: 0,
          outflowDelta: InsightsDelta(current: 0, previous: 0, isNew: false),
          inflowDelta: InsightsDelta(current: 0, previous: 0, isNew: false),
          pillars: [],
        ),
      ),
    );
    final cubit = InsightsCubit(useCase, nowProvider: () => fixedNow);

    await pumpPage(tester, cubit);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Last Quarter'));
    await tester.pumpAndSettle();

    verify(
      () => useCase.call(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.lastQuarter,
          now: fixedNow,
          periodLabel: 'Apr – Jun 2026',
        ),
      ),
    ).called(1);
  });

  testWidgets('shows a failure card when load fails without data',
      (tester) async {
    when(() => useCase.call(any())).thenAnswer(
      (_) async => const Left(Failure.localFailure(message: 'db exploded')),
    );
    final cubit = InsightsCubit(useCase, nowProvider: () => fixedNow);

    await pumpPage(tester, cubit);
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load insights. Pull to retry.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the empty state when the period has no activity',
      (tester) async {
    when(() => useCase.call(any())).thenAnswer(
      (_) async => const Right(
        InsightsSummary(
          totalOutflow: 0,
          totalInflow: 0,
          outflowDelta: InsightsDelta(current: 0, previous: 0, isNew: false),
          inflowDelta: InsightsDelta(current: 0, previous: 0, isNew: false),
          pillars: [],
        ),
      ),
    );
    final cubit = InsightsCubit(useCase, nowProvider: () => fixedNow);

    await pumpPage(tester, cubit);
    await tester.pumpAndSettle();

    expect(find.text('Nothing to analyze yet'), findsOneWidget);
  });
}

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
