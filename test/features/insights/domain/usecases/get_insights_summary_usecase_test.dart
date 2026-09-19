import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/usecases/get_insights_summary_usecase.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockTransactionRepository transactionRepository;
  late MockCategoryRepository categoryRepository;
  late GetInsightsSummaryUseCase useCase;

  const pillarUuid = '11111111-1111-4111-8111-111111111111';
  const subUuid = '22222222-2222-4222-8222-222222222222';
  const envelopeUuid = '33333333-3333-4333-8333-333333333333';
  const otherPillarUuid = '44444444-4444-4444-8444-444444444444';
  const salaryPillarUuid = '55555555-5555-4555-8555-555555555555';
  const missingUuid = '66666666-6666-4666-8666-666666666666';

  final now = DateTime(2026, 9, 15, 10);

  final essential = _category(
    uuid: pillarUuid,
    name: 'Essential',
    type: CategoryType.expense,
  );
  final groceriesHousehold = _category(
    uuid: subUuid,
    name: 'Groceries & Household',
    type: CategoryType.expense,
    parentId: pillarUuid,
  );
  final groceries = _category(
    uuid: envelopeUuid,
    name: 'Groceries',
    type: CategoryType.expense,
    parentId: subUuid,
  );
  final lifestyle = _category(
    uuid: otherPillarUuid,
    name: 'Lifestyle',
    type: CategoryType.expense,
  );
  final salary = _category(
    uuid: salaryPillarUuid,
    name: 'Salary',
    type: CategoryType.income,
  );

  final categories = [
    essential,
    groceriesHousehold,
    groceries,
    lifestyle,
    salary,
  ];

  Transaction tx(
    String id,
    double amount,
    TransactionType type,
    String categoryUuid,
    DateTime date,
  ) {
    return Transaction(
      uuid: UniqueId('aaaaaaaa-0000-4bbb-8bbb-${id.padLeft(12, '0')}'),
      amount: Amount(amount),
      description: StringSingleLine('t$id'),
      date: date,
      categoryUuid: UniqueId(categoryUuid),
      type: type,
    );
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    transactionRepository = MockTransactionRepository();
    categoryRepository = MockCategoryRepository();
    useCase = GetInsightsSummaryUseCase(
      transactionRepository,
      categoryRepository,
    );
    when(() => categoryRepository.watchCategories())
        .thenAnswer((_) => Stream.value(Right(categories)));
  });

  /// The usecase always calls getTransactions in order: current window
  /// first, then the previous window.
  void stubRanges({
    required List<Transaction> current,
    required List<Transaction> previous,
  }) {
    var callIndex = 0;
    when(
      () => transactionRepository.getTransactions(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((invocation) async {
      final isCurrentCall = callIndex.isEven;
      callIndex++;
      return Right(isCurrentCall ? current : previous);
    });
  }

  void stubCapturingRanges(
    List<DateTime> requestedStarts,
    List<DateTime> requestedEnds,
  ) {
    when(
      () => transactionRepository.getTransactions(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((invocation) async {
      requestedStarts.add(invocation.namedArguments[#startDate] as DateTime);
      requestedEnds.add(invocation.namedArguments[#endDate] as DateTime);
      return const Right(<Transaction>[]);
    });
  }

  group('timeframe range resolution', () {
    test('thisMonth requests the full month and prior month', () async {
      final requestedStarts = <DateTime>[];
      final requestedEnds = <DateTime>[];
      stubCapturingRanges(requestedStarts, requestedEnds);

      await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      expect(requestedStarts[0], DateTime.parse('2026-09-01'));
      expect(
        requestedEnds[0],
        DateTime.parse('2026-09-30T23:59:59.999'),
      );
      expect(requestedStarts[1], DateTime.parse('2026-08-01'));
      expect(
        requestedEnds[1],
        DateTime.parse('2026-08-31T23:59:59.999'),
      );
    });

    test('lastQuarter requests Apr-Jun and Jan-Mar', () async {
      final requestedStarts = <DateTime>[];
      final requestedEnds = <DateTime>[];
      stubCapturingRanges(requestedStarts, requestedEnds);

      await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.lastQuarter,
          now: now,
        ),
      );

      expect(requestedStarts[0], DateTime.parse('2026-04-01'));
      expect(
        requestedEnds[0],
        DateTime.parse('2026-06-30T23:59:59.999'),
      );
      expect(requestedStarts[1], DateTime.parse('2026-01-01'));
      expect(
        requestedEnds[1],
        DateTime.parse('2026-03-31T23:59:59.999'),
      );
    });

    test('ytd requests Jan 1 to today and the same span last year', () async {
      final requestedStarts = <DateTime>[];
      final requestedEnds = <DateTime>[];
      stubCapturingRanges(requestedStarts, requestedEnds);

      await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.ytd,
          now: now,
        ),
      );

      expect(requestedStarts[0], DateTime.parse('2026-01-01'));
      expect(requestedEnds[0], DateTime.parse('2026-09-15T23:59:59.999'));
      expect(requestedStarts[1], DateTime.parse('2025-01-01'));
      expect(requestedEnds[1], DateTime.parse('2025-09-15T23:59:59.999'));
    });
  });

  group('aggregation', () {
    test('rolls up L2/L3 transactions to pillars and computes shares',
        () async {
      stubRanges(
        current: [
          tx(
            '1',
            100,
            TransactionType.expense,
            envelopeUuid,
            DateTime(2026, 9, 3),
          ),
          tx(
            '2',
            100,
            TransactionType.expense,
            subUuid,
            DateTime(2026, 9, 5),
          ), // L2 direct
          tx(
            '3',
            300,
            TransactionType.expense,
            pillarUuid,
            DateTime(2026, 9, 7),
          ), // L1 direct
          tx(
            '4',
            300,
            TransactionType.expense,
            otherPillarUuid,
            DateTime(2026, 9, 8),
          ),
        ],
        previous: [
          tx(
            '9',
            200,
            TransactionType.expense,
            pillarUuid,
            DateTime(2026, 8, 2),
          ),
        ],
      );

      final result = await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      final summary = result.fold((_) => fail('expected Right'), (s) => s);
      expect(summary.totalOutflow, 800);
      expect(summary.totalInflow, 0);
      expect(summary.outflowDelta.previous, 200);
      expect(summary.outflowDelta.changePercent, closeTo(300, 0.001));
      expect(summary.outflowDelta.isNew, isFalse);

      // Sorted by activity: Essential 400, Lifestyle 300.
      expect(summary.pillars, hasLength(2));
      final essentialPillar = summary.pillars.first;
      expect(essentialPillar.pillar.uuid.getOrCrash(), pillarUuid);
      expect(essentialPillar.outflow, 500);
      expect(essentialPillar.shareOfTotalOutflow, 0.625);
      // Envelopes: L1 direct 300, Groceries 100, G&H 100 (name tiebreak).
      expect(
        essentialPillar.envelopes.map((e) => e.category.name.getOrCrash()),
        ['Essential', 'Groceries', 'Groceries & Household'],
      );
      expect(essentialPillar.envelopes.last.outflow, 100);
      expect(essentialPillar.envelopes.last.shareOfPillar, closeTo(0.2, 0.001));
      expect(essentialPillar.envelopes.last.transactionCount, 1);
    });

    test('inflow includes income and investment transactions', () async {
      stubRanges(
        current: [
          tx(
            '10',
            500,
            TransactionType.income,
            salaryPillarUuid,
            DateTime(2026, 9, 2),
          ),
          tx(
            '11',
            50,
            TransactionType.investment,
            envelopeUuid,
            DateTime(2026, 9, 4),
          ),
        ],
        previous: [
          tx(
            '12',
            100,
            TransactionType.income,
            salaryPillarUuid,
            DateTime(2026, 8, 2),
          ),
        ],
      );

      final result = await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      final summary = result.fold((_) => fail('expected Right'), (s) => s);
      expect(summary.totalInflow, 550);
      expect(summary.totalOutflow, 0);
      expect(summary.inflowDelta.changePercent, closeTo(450, 0.001));
    });

    test(
        'groups missing-category transactions under one Uncategorized '
        'bucket', () async {
      stubRanges(
        current: [
          tx(
            '20',
            40,
            TransactionType.expense,
            missingUuid,
            DateTime(2026, 9, 3),
          ),
          tx(
            '21',
            60,
            TransactionType.expense,
            missingUuid,
            DateTime(2026, 9, 4),
          ),
        ],
        previous: [],
      );

      final result = await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      final summary = result.fold((_) => fail('expected Right'), (s) => s);
      expect(summary.pillars, hasLength(1));
      final bucket = summary.pillars.first;
      expect(bucket.pillar.name.getOrCrash(), 'Uncategorized');
      expect(bucket.envelopes, hasLength(1));
      expect(bucket.envelopes.first.outflow, 100);
      expect(bucket.envelopes.first.transactionCount, 2);
      expect(bucket.envelopes.first.shareOfPillar, 1.0);
      expect(summary.outflowDelta.isNew, isTrue);
      expect(summary.outflowDelta.changePercent, isNull);
    });

    test('handles empty windows without division errors', () async {
      stubRanges(current: [], previous: []);

      final result = await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      final summary = result.fold((_) => fail('expected Right'), (s) => s);
      expect(summary.totalOutflow, 0);
      expect(summary.totalInflow, 0);
      expect(summary.pillars, isEmpty);
      expect(summary.outflowDelta.changePercent, isNull);
      expect(summary.outflowDelta.isNew, isFalse);
      expect(summary.inflowDelta.changePercent, isNull);
    });

    test('propagates transaction repository failure', () async {
      when(
        () => transactionRepository.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(Failure.localFailure(message: 'db error')),
      );

      final result = await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('db error')),
        (_) => fail('expected Left'),
      );
    });

    test('propagates category repository failure', () async {
      when(() => categoryRepository.watchCategories()).thenAnswer(
        (_) => Stream.value(
          const Left(Failure.localFailure(message: 'cat boom')),
        ),
      );
      stubRanges(current: [], previous: []);

      final result = await useCase(
        GetInsightsSummaryParams(
          timeframe: InsightsTimeframe.thisMonth,
          now: now,
        ),
      );

      expect(result.isLeft(), isTrue);
    });
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
