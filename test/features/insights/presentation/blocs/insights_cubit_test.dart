import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:expense_tracker/features/insights/domain/usecases/get_insights_summary_usecase.dart';
import 'package:expense_tracker/features/insights/presentation/blocs/insights_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetInsightsSummaryUseCase extends Mock
    implements GetInsightsSummaryUseCase {}

void main() {
  late MockGetInsightsSummaryUseCase useCase;
  late InsightsCubit cubit;

  final fixedNow = DateTime(2026, 9, 15, 10);

  final summary = InsightsSummary(
    totalOutflow: 500,
    totalInflow: 300,
    outflowDelta: InsightsDelta.calculate(current: 500, previous: 400),
    inflowDelta: InsightsDelta.calculate(current: 300, previous: 350),
    pillars: const [],
  );

  final thisMonthParams = GetInsightsSummaryParams(
    timeframe: InsightsTimeframe.thisMonth,
    now: fixedNow,
  );
  final lastQuarterParams = GetInsightsSummaryParams(
    timeframe: InsightsTimeframe.lastQuarter,
    now: fixedNow,
  );

  setUpAll(() {
    registerFallbackValue(
      GetInsightsSummaryParams(
        timeframe: InsightsTimeframe.thisMonth,
        now: fixedNow,
      ),
    );
  });

  setUp(() {
    useCase = MockGetInsightsSummaryUseCase();
    cubit = InsightsCubit(useCase, nowProvider: () => fixedNow);
  });

  tearDown(() => cubit.close());

  /// Collects emitted states for transition assertions.
  List<InsightsState> emittedStates(InsightsCubit cubit) {
    final states = <InsightsState>[];
    cubit.stream.listen(states.add);
    return states;
  }

  test('initial state is initial + thisMonth with no summary', () {
    expect(cubit.state.status, InsightsStatus.initial);
    expect(cubit.state.selectedTimeframe, InsightsTimeframe.thisMonth);
    expect(cubit.state.summary, isNull);
    expect(cubit.state.failureOption.isNone(), isTrue);
  });

  test('load emits loading then loaded with the summary', () async {
    when(() => useCase.call(thisMonthParams))
        .thenAnswer((_) async => Right(summary));
    final states = emittedStates(cubit);

    await cubit.load();
    // Broadcast deliveries land in microtasks — flush before asserting.
    await Future<void>.delayed(Duration.zero);

    expect(
      states.map((s) => s.status).toList(),
      const [InsightsStatus.loading, InsightsStatus.loaded],
    );
    expect(cubit.state.summary, same(summary));
    expect(cubit.state.failureOption.isNone(), isTrue);
    verify(() => useCase.call(thisMonthParams)).called(1);
  });

  test('load emits failure with the failure option populated', () async {
    const failure = Failure.localFailure(message: 'boom');
    when(() => useCase.call(thisMonthParams))
        .thenAnswer((_) async => const Left(failure));

    await cubit.load();

    expect(cubit.state.status, InsightsStatus.failure);
    expect(cubit.state.failureOption.isSome(), isTrue);
    expect(
      cubit.state.failureOption.fold(() => null, (f) => f.message),
      contains('boom'),
    );
    expect(cubit.state.summary, isNull);
  });

  test('selectTimeframe re-fetches with the new timeframe params', () async {
    final quarterSummary = InsightsSummary(
      totalOutflow: 100,
      totalInflow: 200,
      outflowDelta: InsightsDelta.calculate(current: 100, previous: 90),
      inflowDelta: InsightsDelta.calculate(current: 200, previous: 180),
      pillars: const [],
    );
    when(() => useCase.call(thisMonthParams))
        .thenAnswer((_) async => Right(summary));
    when(() => useCase.call(lastQuarterParams))
        .thenAnswer((_) async => Right(quarterSummary));

    await cubit.selectTimeframe(InsightsTimeframe.lastQuarter);

    expect(cubit.state.selectedTimeframe, InsightsTimeframe.lastQuarter);
    expect(cubit.state.status, InsightsStatus.loaded);
    expect(cubit.state.summary, same(quarterSummary));
    verify(() => useCase.call(lastQuarterParams)).called(1);
    verifyNever(() => useCase.call(thisMonthParams));
  });

  test('refresh re-fetches the current timeframe', () async {
    when(() => useCase.call(thisMonthParams))
        .thenAnswer((_) async => Right(summary));

    await cubit.refresh();

    verify(() => useCase.call(thisMonthParams)).called(1);
  });

  test('rapid timeframe switches keep only the newest response', () async {
    final staleCompleter = Completer<Either<Failure, InsightsSummary>>();
    when(() => useCase.call(thisMonthParams))
        .thenAnswer((_) => staleCompleter.future);
    when(() => useCase.call(lastQuarterParams))
        .thenAnswer((_) async => const Right(quarterSummaryFixture));

    final loadFuture = cubit.load(); // thisMonth — slow (stale)
    await cubit.selectTimeframe(InsightsTimeframe.lastQuarter); // fast, new
    expect(cubit.state.summary, same(quarterSummaryFixture));

    // The stale response lands late and must be discarded.
    staleCompleter.complete(Right(summary));
    await loadFuture;

    expect(cubit.state.summary, same(quarterSummaryFixture));
    expect(cubit.state.status, InsightsStatus.loaded);
    expect(cubit.state.selectedTimeframe, InsightsTimeframe.lastQuarter);
  });
}

const quarterSummaryFixture = InsightsSummary(
  totalOutflow: 100,
  totalInflow: 200,
  outflowDelta: InsightsDelta(current: 100, previous: 90, isNew: false),
  inflowDelta: InsightsDelta(current: 200, previous: 150, isNew: false),
  pillars: [],
);
