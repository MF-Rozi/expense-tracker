import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/insights/domain/entities/insight_timeframe.dart';
import 'package:expense_tracker/features/insights/domain/entities/insights_summary.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Aggregates transactions for the requested timeframe into an
/// [InsightsSummary]: inflow/outflow totals, period-over-period deltas,
/// and the Level-1 pillar distribution with per-envelope detail.
///
/// Amounts are bucketed by [TransactionType] — never by category type —
/// because `TransactionType.investment` has no matching `CategoryType`.
@lazySingleton
class GetInsightsSummaryUseCase
    extends UseCase<InsightsSummary, GetInsightsSummaryParams> {
  GetInsightsSummaryUseCase(
    this._transactionRepository,
    this._categoryRepository,
  );

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  @override
  Future<Either<Failure, InsightsSummary>> call(
    GetInsightsSummaryParams params,
  ) async {
    final window = _resolveWindow(params);

    final categoriesResult = await _categoryRepository.watchCategories().first;
    final currentResult = await _transactionRepository.getTransactions(
      startDate: window?.current.start,
      endDate: window?.current.end,
    );
    var previous = const <Transaction>[];
    if (window != null) {
      final previousResult = await _transactionRepository.getTransactions(
        startDate: window.previous.start,
        endDate: window.previous.end,
      );
      previous = previousResult.fold((_) => <Transaction>[], (t) => t);
    }

    final failure = categoriesResult.fold((f) => f, (_) => null) ??
        currentResult.fold((f) => f, (_) => null);
    if (failure != null) {
      return Left(failure);
    }

    final categories = categoriesResult.fold((_) => <Category>[], (c) => c);
    final current = currentResult.fold((_) => <Transaction>[], (t) => t);

    return Right(
      _aggregate(
        currentTransactions: current,
        previousTransactions: previous,
        categories: categories,
        hasPreviousWindow: window != null,
        periodLabel: params.periodLabel,
      ),
    );
  }

  /// Null window means "all time" — a single unfiltered fetch with no
  /// period-over-period comparison.
  InsightsWindow? _resolveWindow(GetInsightsSummaryParams params) {
    switch (params.timeframe) {
      case InsightsTimeframe.allTime:
        return null;
      case InsightsTimeframe.custom:
        final customRange = params.customRange;
        if (customRange == null) {
          throw ArgumentError(
            'timeframe custom requires customRange in the params',
          );
        }
        return InsightsWindow(
          current: customRange,
          previous: customRange.previousEqualLength(),
        );
      case InsightsTimeframe.thisMonth:
      case InsightsTimeframe.lastQuarter:
      case InsightsTimeframe.ytd:
        return params.timeframe.resolve(params.now);
    }
  }

  InsightsSummary _aggregate({
    required List<Transaction> currentTransactions,
    required List<Transaction> previousTransactions,
    required List<Category> categories,
    required bool hasPreviousWindow,
    required String periodLabel,
  }) {
    final categoryByUuid = <String, Category>{
      for (final category in categories) category.uuid.getOrCrash(): category,
    };
    // One stable bucket per aggregation run so all missing-category
    // transactions land in the same "Uncategorized" pillar.
    final uncategorized = _uncategorizedCategory();

    double previousOutflow = 0;
    double previousInflow = 0;
    for (final transaction in previousTransactions) {
      if (transaction.type == TransactionType.expense) {
        previousOutflow += transaction.amount.getOrCrash();
      } else {
        previousInflow += transaction.amount.getOrCrash();
      }
    }

    final pillarAccumulators = <String, _PillarAccumulator>{};
    for (final transaction in currentTransactions) {
      final amount = transaction.amount.getOrCrash();
      final category = categoryByUuid[transaction.categoryUuid.getOrCrash()] ??
          uncategorized;
      final pillar = category.getRootPillar(categories);
      final envelopeKey = category.uuid.getOrCrash();

      final accumulator = pillarAccumulators.putIfAbsent(
        pillar.uuid.getOrCrash(),
        () => _PillarAccumulator(pillar: pillar),
      );
      final envelope = accumulator.envelopes.putIfAbsent(
        envelopeKey,
        () => _EnvelopeAccumulator(
          category: category,
          breadcrumb: category.getBreadcrumbPath(categories),
        ),
      );

      if (transaction.type == TransactionType.expense) {
        accumulator.outflow += amount;
        envelope.outflow += amount;
      } else {
        accumulator.inflow += amount;
        envelope.inflow += amount;
      }
      envelope.transactionCount++;
    }

    var totalOutflow = 0.0;
    var totalInflow = 0.0;
    for (final accumulator in pillarAccumulators.values) {
      totalOutflow += accumulator.outflow;
      totalInflow += accumulator.inflow;
    }

    final pillars = pillarAccumulators.values
        .map(
          (accumulator) => accumulator.toInsight(
            totalOutflow: totalOutflow,
            categories: categories,
          ),
        )
        .toList()
      ..sort(_compareByActivity);

    // Without a previous window (All Time) the deltas render as a dash
    // instead of a meaningless comparison.
    final outflowDelta = hasPreviousWindow
        ? InsightsDelta.calculate(
            current: totalOutflow,
            previous: previousOutflow,
          )
        : InsightsDelta(current: totalOutflow, previous: 0, isNew: false);
    final inflowDelta = hasPreviousWindow
        ? InsightsDelta.calculate(
            current: totalInflow,
            previous: previousInflow,
          )
        : InsightsDelta(current: totalInflow, previous: 0, isNew: false);

    return InsightsSummary(
      periodLabel: periodLabel,
      totalOutflow: totalOutflow,
      totalInflow: totalInflow,
      outflowDelta: outflowDelta,
      inflowDelta: inflowDelta,
      pillars: pillars,
    );
  }

  int _compareByActivity(PillarInsight a, PillarInsight b) {
    final activityA = a.outflow + a.inflow;
    final activityB = b.outflow + b.inflow;
    if (activityA != activityB) return activityB.compareTo(activityA);
    final nameA = a.pillar.name.getOrCrash().toLowerCase();
    final nameB = b.pillar.name.getOrCrash().toLowerCase();
    return nameA.compareTo(nameB);
  }

  /// Fallback bucket for transactions whose category no longer exists;
  /// never dropped silently.
  Category _uncategorizedCategory() => Category(
        uuid: UniqueId(const Uuid().v4()),
        name: StringSingleLine('Uncategorized'),
        isSynced: false,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        type: CategoryType.expense,
        expectedMonthlyBudget: 0,
        behavioralModifier: BehavioralModifier.active,
      );
}

class GetInsightsSummaryParams extends Equatable {
  const GetInsightsSummaryParams({
    required this.timeframe,
    required this.now,
    this.customRange,
    this.periodLabel = '',
  });

  final InsightsTimeframe timeframe;
  final DateTime now;

  /// Required when [timeframe] is `custom`; ignored otherwise.
  final DateRange? customRange;

  /// Human-readable window label computed by the caller so the summary
  /// carries everything the UI renders.
  final String periodLabel;

  @override
  List<Object?> get props => [timeframe, now, customRange, periodLabel];
}

class _EnvelopeAccumulator {
  _EnvelopeAccumulator({required this.category, required this.breadcrumb});

  final Category category;
  final String breadcrumb;
  double outflow = 0;
  double inflow = 0;
  int transactionCount = 0;

  EnvelopeInsight toInsight({
    required double pillarActivity,
    required List<Category> categories,
  }) {
    final activity = outflow + inflow;
    return EnvelopeInsight(
      category: category,
      breadcrumb: category.getBreadcrumbPath(categories),
      outflow: outflow,
      inflow: inflow,
      transactionCount: transactionCount,
      shareOfPillar: pillarActivity == 0 ? 0 : activity / pillarActivity,
    );
  }
}

class _PillarAccumulator {
  _PillarAccumulator({required this.pillar});

  final Category pillar;
  double outflow = 0;
  double inflow = 0;
  final Map<String, _EnvelopeAccumulator> envelopes = {};

  PillarInsight toInsight({
    required double totalOutflow,
    required List<Category> categories,
  }) {
    final pillarActivity = outflow + inflow;
    return PillarInsight(
      pillar: pillar,
      outflow: outflow,
      inflow: inflow,
      shareOfTotalOutflow: totalOutflow == 0 ? 0 : outflow / totalOutflow,
      envelopes: envelopes.values
          .map(
            (envelope) => envelope.toInsight(
              pillarActivity: pillarActivity,
              categories: categories,
            ),
          )
          .toList()
        ..sort((a, b) {
          final activityA = a.outflow + a.inflow;
          final activityB = b.outflow + b.inflow;
          if (activityA != activityB) return activityB.compareTo(activityA);
          final nameA = a.category.name.getOrCrash().toLowerCase();
          final nameB = b.category.name.getOrCrash().toLowerCase();
          return nameA.compareTo(nameB);
        }),
    );
  }
}
