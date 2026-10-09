import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/app_open_repository.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements TransactionRepository {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAppOpenRepository extends Mock implements AppOpenRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockTransactionRepository mockTxRepo;
  late MockLocalStorage mockStorage;
  late MockAppOpenRepository mockAppOpenRepo;
  late MockCategoryRepository mockCategoryRepo;
  late StreakRepositoryImpl repository;

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    mockStorage = MockLocalStorage();
    mockAppOpenRepo = MockAppOpenRepository();
    mockCategoryRepo = MockCategoryRepository();
    repository = StreakRepositoryImpl(
      mockTxRepo,
      mockStorage,
      mockAppOpenRepo,
      mockCategoryRepo,
    );

    // Default storage mocks
    when(() => mockStorage.getStreakWindowDays()).thenAnswer((_) async => 3);
    when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 3);
    when(() => mockStorage.getAppOpenCadenceDays()).thenAnswer((_) async => 7);
    when(() => mockCategoryRepo.watchCategories())
        .thenAnswer((_) => Stream.value(const Right([])));
  });

  Transaction createTx(
    DateTime date, {
    TransactionType type = TransactionType.expense,
    double amount = 100,
    UniqueId? categoryUuid,
  }) {
    return Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(amount),
      description: StringSingleLine('Test transaction'),
      date: date,
      categoryUuid: categoryUuid ?? UniqueId.generate(),
      type: type,
    );
  }

  Category createCategory({
    required UniqueId uuid,
    required String name,
    UniqueId? parentId,
    double budget = 0,
    CategoryType type = CategoryType.expense,
  }) {
    return Category(
      uuid: uuid,
      name: StringSingleLine(name),
      parentId: parentId,
      isSynced: false,
      updatedAt: DateTime.now(),
      type: type,
      expectedMonthlyBudget: budget,
      behavioralModifier: BehavioralModifier.active,
    );
  }

  List<Category> createStandardTestCategories({
    required Map<UniqueId, double> leafBudgets,
  }) {
    final pillarId = UniqueId.generate();
    final subParentId = UniqueId.generate();
    final categories = <Category>[
      createCategory(uuid: pillarId, name: 'Essential'),
      createCategory(uuid: subParentId, name: 'Living', parentId: pillarId),
    ];

    leafBudgets.forEach((leafId, budget) {
      final idStr = leafId.getOrCrash();
      final suffix = idStr.length >= 4 ? idStr.substring(0, 4) : idStr;
      categories.add(
        createCategory(
          uuid: leafId,
          name: 'Envelope $suffix',
          parentId: subParentId,
          budget: budget,
        ),
      );
    });

    return categories;
  }

  group('StreakRepositoryImpl.getStreak - Tracking', () {
    test(
        'Records discrete transaction dates and produces active streak '
        'when meeting minimum count', () async {
      final refDate = DateTime(2026, 9, 25, 14);
      final transactions = [
        createTx(DateTime(2026, 9, 21, 10)),
        createTx(DateTime(2026, 9, 22, 11)),
        createTx(DateTime(2026, 9, 23, 9)),
        createTx(DateTime(2026, 9, 24, 15)),
        createTx(DateTime(2026, 9, 25, 12)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 5);
          expect(streak.status, StreakStatus.active);
          expect(streak.bestLength, 5);
          expect(streak.daysUntilBreak, 3);
        },
      );
    });

    test('Warming up when count is below minimum', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      final transactions = [
        createTx(DateTime(2026, 9, 24, 10)),
        createTx(DateTime(2026, 9, 25, 12)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 2);
          expect(streak.status, StreakStatus.warmingUp);
        },
      );
    });

    test('At risk when last recorded transaction was at the edge of window',
        () async {
      final refDate = DateTime(2026, 9, 25, 12);
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10)),
        createTx(DateTime(2026, 9, 21, 10)),
        createTx(DateTime(2026, 9, 22, 10)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.atRisk);
          expect(streak.daysUntilBreak, 1);
        },
      );
    });

    test('Broken when gap exceeds window', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      final transactions = [
        createTx(DateTime(2026, 9, 18, 10)),
        createTx(DateTime(2026, 9, 19, 10)),
        createTx(DateTime(2026, 9, 20, 10)),
        createTx(DateTime(2026, 9, 21, 10)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(referenceDate: refDate);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.broken);
          expect(streak.bestLength, 4);
        },
      );
    });

    test('Empty transactions returns empty streak', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await repository.getStreak();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.isEmpty, isTrue);
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.none);
        },
      );
    });

    test('Propagates TransactionRepository failure as Left', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          Failure.localFailure(message: 'Database query failed'),
        ),
      );

      final result = await repository.getStreak();

      expect(result.isLeft(), isTrue);
    });
  });

  group('StreakRepositoryImpl.getStreak - No-Spend', () {
    test(
        'Expense-free days build a run; any expense that day '
        'disqualifies only that day', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 21, 11), type: TransactionType.income),
        createTx(DateTime(2026, 9, 22, 12)),
        createTx(DateTime(2026, 9, 23, 14), type: TransactionType.income),
        createTx(DateTime(2026, 9, 24, 15), type: TransactionType.income),
        createTx(DateTime(2026, 9, 25, 9), type: TransactionType.income),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 6);
          expect(streak.status, StreakStatus.active);
          expect(streak.daysUntilBreak, 3);
        },
      );
    });

    test(
        'Expense on last day of window coverage -> '
        'at risk with 1 day until break', () async {
      final refDate = DateTime(2026, 9, 25, 12);
      final transactions = [
        createTx(DateTime(2026, 9, 20, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 21, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 22, 10), type: TransactionType.income),
        createTx(DateTime(2026, 9, 23, 10)),
        createTx(DateTime(2026, 9, 24, 10)),
        createTx(DateTime(2026, 9, 25, 10)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.noSpend,
        referenceDate: refDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.atRisk);
          expect(streak.daysUntilBreak, 1);
        },
      );
    });

    test('Empty transactions -> empty noSpend streak', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await repository.getStreak(type: StreakType.noSpend);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.isEmpty, isTrue);
          expect(streak.length, 0);
        },
      );
    });
  });

  group('StreakRepositoryImpl.getStreak - App-Open Consistency', () {
    test(
        'Covers AE5: Cadence 1 consecutive-day opens sustain run; '
        'skipped day consumes capacity -> at risk then broken', () async {
      when(() => mockStorage.getAppOpenCadenceDays())
          .thenAnswer((_) async => 1);
      final openDates = [
        DateTime(2026, 9, 20, 9),
        DateTime(2026, 9, 21, 10),
        DateTime(2026, 9, 22, 8),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(openDates));

      final resultDay22 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 22, 12),
      );
      resultDay22.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.active);
          expect(streak.daysUntilBreak, 1);
        },
      );

      final resultDay23 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 23, 12),
      );
      resultDay23.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 3);
          expect(streak.status, StreakStatus.atRisk);
          expect(streak.daysUntilBreak, 1);
        },
      );

      final resultDay24 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 24, 12),
      );
      resultDay24.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.broken);
          expect(streak.bestLength, 3);
        },
      );
    });

    test(
        'Covers AE6: Cadence 7 opens on 1st and 7th continue; '
        '9th breaks', () async {
      when(() => mockStorage.getAppOpenCadenceDays())
          .thenAnswer((_) async => 7);
      when(() => mockStorage.getStreakMinimumDays())
          .thenAnswer((_) async => 1);

      final opensSustained = [
        DateTime(2026, 9, 1, 9),
        DateTime(2026, 9, 7, 10),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(opensSustained));

      final resultSept7 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 7, 12),
      );
      resultSept7.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 7);
          expect(streak.status, StreakStatus.active);
        },
      );

      final opensBroken = [
        DateTime(2026, 9, 1, 9),
        DateTime(2026, 9, 9, 10),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(opensBroken));

      final resultSept9 = await repository.getStreak(
        type: StreakType.appOpen,
        referenceDate: DateTime(2026, 9, 9, 12),
      );
      resultSept9.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 1);
          expect(streak.bestLength, 1);
        },
      );
    });
  });

  group('StreakRepositoryImpl.getStreak - Under-Budget (Phase 3)', () {
    test(
        'Covers AE7: Mid-month overspend leaves the count unchanged; '
        'preview shows off track', () async {
      when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 1);

      final leafId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {leafId: 1000},
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      final transactions = [
        createTx(DateTime(2026, 3, 10), amount: 600, categoryUuid: leafId),
        createTx(DateTime(2026, 4, 12), amount: 1500, categoryUuid: leafId),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.underBudget,
        referenceDate: DateTime(2026, 4, 15),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 1);
          expect(streak.status, StreakStatus.active);
          expect(streak.isCurrentMonthOnTrack, isFalse);
        },
      );
    });

    test(
        'Covers AE8: Completed month within total budgets with one category '
        'over its budget -> qualifies for streak', () async {
      when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 1);

      final groceriesId = UniqueId.generate();
      final diningId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {
          groceriesId: 300,
          diningId: 700,
        },
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      final transactions = [
        createTx(
          DateTime(2026, 3, 10),
          amount: 400,
          categoryUuid: groceriesId,
        ),
        createTx(
          DateTime(2026, 3, 15),
          amount: 400,
          categoryUuid: diningId,
        ),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.underBudget,
        referenceDate: DateTime(2026, 4, 10),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 1);
          expect(streak.status, StreakStatus.active);
        },
      );

      final flagsResult = await repository.getCategoryOverrunFlags(
        month: DateTime(2026, 3),
      );
      expect(flagsResult.isRight(), isTrue);
      flagsResult.fold(
        (_) => fail('Expected Right'),
        (flags) {
          expect(flags.length, 1);
          expect(flags.first.categoryUuid, groceriesId.getOrCrash());
          expect(flags.first.budget, 300.0);
          expect(flags.first.spent, 400.0);
          expect(flags.first.overrunAmount, 100.0);
        },
      );
    });

    test('Completed month over total budgets -> run breaks at that month',
        () async {
      when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 1);

      final leafId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {leafId: 1000},
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      final transactions = [
        createTx(DateTime(2026, 1, 10), amount: 800, categoryUuid: leafId),
        createTx(DateTime(2026, 2, 10), amount: 1400, categoryUuid: leafId),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.underBudget,
        referenceDate: DateTime(2026, 3, 15),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 0);
          expect(streak.status, StreakStatus.broken);
          expect(streak.bestLength, 1);
        },
      );
    });

    test('Month with zero budgets configured (all zeros) -> not qualifying',
        () async {
      when(() => mockStorage.getStreakMinimumDays()).thenAnswer((_) async => 1);

      final leafId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {leafId: 0},
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      final transactions = [
        createTx(DateTime(2026, 3, 10), amount: 0, categoryUuid: leafId),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getStreak(
        type: StreakType.underBudget,
        referenceDate: DateTime(2026, 4, 15),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (streak) {
          expect(streak.length, 0);
          expect(streak.isCurrentMonthOnTrack, isFalse);
        },
      );
    });

    test(
      'Year-boundary consecutive months (Dec, Jan) compute correctly on the '
      'month engine',
      () async {
        when(() => mockStorage.getStreakMinimumDays())
            .thenAnswer((_) async => 2);

        final leafId = UniqueId.generate();
        final categories = createStandardTestCategories(
          leafBudgets: {leafId: 1000},
        );
        when(() => mockCategoryRepo.watchCategories())
            .thenAnswer((_) => Stream.value(Right(categories)));

        final transactions = [
          createTx(DateTime(2025, 12, 15), amount: 700, categoryUuid: leafId),
          createTx(DateTime(2026, 1, 15), amount: 800, categoryUuid: leafId),
        ];

        when(
          () => mockTxRepo.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(transactions));

        final result = await repository.getStreak(
          type: StreakType.underBudget,
          referenceDate: DateTime(2026, 2, 15),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (streak) {
            expect(streak.length, 2);
            expect(streak.status, StreakStatus.active);
          },
        );
      },
    );

    test('isCurrentMonthOnTrack returns boolean based on total budget',
        () async {
      final leafId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {leafId: 1000},
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => Right([
          createTx(DateTime(2026, 4, 5), amount: 400, categoryUuid: leafId),
        ]),
      );

      final onTrackResult = await repository.isCurrentMonthOnTrack(
        referenceDate: DateTime(2026, 4, 15),
      );
      expect(onTrackResult, const Right<Failure, bool>(true));
    });

    test('getUnderBudgetStatus aggregates budget, spent, and flags', () async {
      final leafId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {leafId: 1000},
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => Right([
          createTx(DateTime(2026, 4, 5), amount: 650, categoryUuid: leafId),
        ]),
      );

      final statusResult = await repository.getUnderBudgetStatus(
        month: DateTime(2026, 4),
      );

      expect(statusResult.isRight(), isTrue);
      statusResult.fold(
        (_) => fail('Expected Right'),
        (status) {
          expect(status.totalBudget, 1000.0);
          expect(status.totalSpent, 650.0);
          expect(status.isOnTrack, isTrue);
          expect(status.remainingBudget, 350.0);
        },
      );
    });
  });

  group('StreakRepositoryImpl.getQualifyingPeriods', () {
    test('extracts, deduplicates, and sorts qualifying dates for tracking',
        () async {
      final startDate = DateTime(2026, 9);
      final endDate = DateTime(2026, 9, 30);
      final transactions = [
        createTx(DateTime(2026, 9, 5, 10)),
        createTx(DateTime(2026, 9, 2, 8)),
        createTx(DateTime(2026, 9, 5, 16)),
        createTx(DateTime(2026, 9, 10, 12)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: startDate,
          endDate: endDate,
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getQualifyingPeriods(
        startDate: startDate,
        endDate: endDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakDay.fromYmd(2026, 9, 2),
            const StreakDay.fromYmd(2026, 9, 5),
            const StreakDay.fromYmd(2026, 9, 10),
          ]);
        },
      );
    });

    test('extracts qualifying dates for noSpend (expense-free days)', () async {
      final startDate = DateTime(2026, 9);
      final endDate = DateTime(2026, 9, 5);
      final transactions = [
        createTx(DateTime(2026, 9, 2, 10)),
        createTx(DateTime(2026, 9, 4, 14)),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: startDate,
          endDate: endDate,
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getQualifyingPeriods(
        type: StreakType.noSpend,
        startDate: startDate,
        endDate: endDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakDay.fromYmd(2026, 9, 1),
            const StreakDay.fromYmd(2026, 9, 3),
            const StreakDay.fromYmd(2026, 9, 5),
          ]);
        },
      );
    });

    test('extracts, deduplicates, and sorts open dates for appOpen', () async {
      final startDate = DateTime(2026, 9);
      final endDate = DateTime(2026, 9, 30);
      final openDates = [
        DateTime(2026, 9, 5, 10),
        DateTime(2026, 9, 2, 8),
        DateTime(2026, 9, 5, 16),
        DateTime(2026, 9, 10, 12),
      ];

      when(
        () => mockAppOpenRepo.getOpenDates(
          startDate: startDate,
          endDate: endDate,
        ),
      ).thenAnswer((_) async => Right(openDates));

      final result = await repository.getQualifyingPeriods(
        type: StreakType.appOpen,
        startDate: startDate,
        endDate: endDate,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakDay.fromYmd(2026, 9, 2),
            const StreakDay.fromYmd(2026, 9, 5),
            const StreakDay.fromYmd(2026, 9, 10),
          ]);
        },
      );
    });

    test('extracts qualifying StreakMonths for underBudget', () async {
      final leafId = UniqueId.generate();
      final categories = createStandardTestCategories(
        leafBudgets: {leafId: 1000},
      );
      when(() => mockCategoryRepo.watchCategories())
          .thenAnswer((_) => Stream.value(Right(categories)));

      final transactions = [
        createTx(DateTime(2025, 11, 10), amount: 800, categoryUuid: leafId),
        createTx(DateTime(2025, 12, 10), amount: 900, categoryUuid: leafId),
      ];

      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(transactions));

      final result = await repository.getQualifyingPeriods(
        type: StreakType.underBudget,
        startDate: DateTime(2025, 11),
        endDate: DateTime(2025, 12, 31),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (periods) {
          expect(periods, [
            const StreakMonth(2025, 11),
            const StreakMonth(2025, 12),
          ]);
        },
      );
    });

    test('propagates repository failure as Left', () async {
      when(
        () => mockTxRepo.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          Failure.localFailure(message: 'Failed to read records'),
        ),
      );

      final result = await repository.getQualifyingPeriods();

      expect(result.isLeft(), isTrue);
    });
  });
}
