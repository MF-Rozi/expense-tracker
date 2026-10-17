import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_qualifying_periods_use_case.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_streaks_use_case.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_under_budget_status_use_case.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_cubit.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/usecases/watch_transactions_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetStreaksUseCase extends Mock implements GetStreaksUseCase {}

class MockGetQualifyingPeriodsUseCase extends Mock
    implements GetQualifyingPeriodsUseCase {}

class MockWatchTransactionsUseCase extends Mock
    implements WatchTransactionsUseCase {}

class MockGetUnderBudgetStatusUseCase extends Mock
    implements GetUnderBudgetStatusUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GetStreaksParams());
    registerFallbackValue(const GetQualifyingPeriodsParams());
    registerFallbackValue(const GetUnderBudgetStatusParams());
    registerFallbackValue(NoParams());
  });

  late MockGetStreaksUseCase mockGetStreaksUseCase;
  late MockGetQualifyingPeriodsUseCase mockGetQualifyingPeriodsUseCase;
  late MockWatchTransactionsUseCase mockWatchTransactionsUseCase;
  late MockGetUnderBudgetStatusUseCase mockGetUnderBudgetStatusUseCase;
  late StreamController<Either<Failure, List<Transaction>>>
      transactionsController;

  final fixedDate = DateTime(2026, 4, 15);
  final fixedMonth = DateTime(2026, 4);

  const tStreak = Streak(
    type: StreakType.tracking,
    length: 5,
    status: StreakStatus.active,
    daysUntilBreak: 3,
    nextMilestone: 7,
    consistencyRate: 0.5,
  );

  final tUnderBudgetStatus = UnderBudgetMonthStatus(
    month: fixedMonth,
    totalBudget: 1000,
    totalSpent: 600,
    isOnTrack: true,
    overrunFlags: const [
      CategoryOverrunFlag(
        categoryUuid: 'dining-123',
        categoryName: 'Dining Out',
        budget: 200,
        spent: 250,
      ),
    ],
  );

  setUp(() {
    mockGetStreaksUseCase = MockGetStreaksUseCase();
    mockGetQualifyingPeriodsUseCase = MockGetQualifyingPeriodsUseCase();
    mockWatchTransactionsUseCase = MockWatchTransactionsUseCase();
    mockGetUnderBudgetStatusUseCase = MockGetUnderBudgetStatusUseCase();
    transactionsController = StreamController.broadcast();

    when(() => mockWatchTransactionsUseCase(any()))
        .thenAnswer((_) => transactionsController.stream);

    when(() => mockGetStreaksUseCase(any()))
        .thenAnswer((_) async => const Right(tStreak));

    when(() => mockGetUnderBudgetStatusUseCase(any()))
        .thenAnswer((_) async => Right(tUnderBudgetStatus));

    when(() => mockGetQualifyingPeriodsUseCase(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.first as GetQualifyingPeriodsParams;
      final m = params.startDate?.month ?? 4;
      return Future.value(
        Right([
          StreakDay(DateTime(2026, m, 10)),
          StreakDay(DateTime(2026, m, 11)),
          StreakDay(DateTime(2026, m, 12)),
        ]),
      );
    });
  });

  tearDown(() {
    transactionsController.close();
  });

  StreakCubit buildCubit({
    DateTime Function()? clock,
    StreakType initialType = StreakType.tracking,
  }) {
    return StreakCubit.test(
      getStreaksUseCase: mockGetStreaksUseCase,
      getQualifyingPeriodsUseCase: mockGetQualifyingPeriodsUseCase,
      watchTransactionsUseCase: mockWatchTransactionsUseCase,
      getUnderBudgetStatusUseCase: mockGetUnderBudgetStatusUseCase,
      clock: clock ?? () => fixedDate,
      initialType: initialType,
    );
  }

  group('StreakCubit', () {
    test('initial state has loading true and empty streak', () {
      final cubit = buildCubit();

      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.streak, equals(const Streak.empty()));
      expect(cubit.state.selectedMonth, equals(fixedMonth));
      expect(cubit.state.qualifyingDays, isEmpty);
      expect(cubit.state.type, equals(StreakType.tracking));
    });

    test('load populates streak, qualifying days, and consistency rate',
        () async {
      final cubit = buildCubit();

      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.streak, equals(tStreak));
      expect(cubit.state.qualifyingDays.length, equals(3));
      // 3 qualifying days out of 15 elapsed days in April = 0.20
      expect(cubit.state.monthlyConsistencyRate, closeTo(0.2, 0.001));
      expect(cubit.state.failureOption.isNone(), isTrue);
    });

    test('selectType updates type and reloads data for the selected type',
        () async {
      final cubit = buildCubit();
      await cubit.load();

      clearInteractions(mockGetStreaksUseCase);
      clearInteractions(mockGetQualifyingPeriodsUseCase);

      const appOpenStreak = Streak(
        type: StreakType.appOpen,
        length: 7,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 14,
        consistencyRate: 0.7,
      );

      when(() => mockGetStreaksUseCase(any()))
          .thenAnswer((_) async => const Right(appOpenStreak));

      await cubit.selectType(StreakType.appOpen);

      expect(cubit.state.type, equals(StreakType.appOpen));
      expect(cubit.state.streak, equals(appOpenStreak));

      verify(
        () => mockGetStreaksUseCase(
          any(
            that: isA<GetStreaksParams>().having(
              (p) => p.type,
              'type',
              StreakType.appOpen,
            ),
          ),
        ),
      ).called(1);
    });

    test('selectType with underBudget loads budget status and overrun flags',
        () async {
      final cubit = buildCubit();
      await cubit.load();

      const underBudgetStreak = Streak(
        type: StreakType.underBudget,
        length: 2,
        status: StreakStatus.active,
        daysUntilBreak: 1,
        nextMilestone: 3,
        consistencyRate: 1,
        isCurrentMonthOnTrack: true,
      );

      when(() => mockGetStreaksUseCase(any()))
          .thenAnswer((_) async => const Right(underBudgetStreak));

      await cubit.selectType(StreakType.underBudget);

      expect(cubit.state.type, equals(StreakType.underBudget));
      expect(cubit.state.streak, equals(underBudgetStreak));
      expect(cubit.state.underBudgetStatus, equals(tUnderBudgetStatus));
      expect(cubit.state.isOnTrack, isTrue);
      expect(cubit.state.currentMonthBudget, 1000);
      expect(cubit.state.currentMonthExpense, 600);
      expect(cubit.state.categoryOverrunFlags.length, 1);
      expect(cubit.state.categoryOverrunFlags.first.categoryName, 'Dining Out');
    });

    test('selectType does nothing if target type is already active', () async {
      final cubit = buildCubit();
      await cubit.load();

      clearInteractions(mockGetStreaksUseCase);
      await cubit.selectType(StreakType.tracking);

      verifyNever(() => mockGetStreaksUseCase(any()));
    });

    test('previousMonth navigates to prior month and calculates full rate',
        () async {
      final cubit = buildCubit();
      await cubit.previousMonth();

      expect(cubit.state.selectedMonth, equals(DateTime(2026, 3)));
      // March 2026 has 31 days; 3 qualifying days -> 3 / 31 = 0.0967...
      expect(cubit.state.monthlyConsistencyRate, closeTo(3 / 31, 0.001));
    });

    test('nextMonth navigates forward and returns 0 for future month',
        () async {
      final cubit = buildCubit();
      await cubit.nextMonth();

      expect(cubit.state.selectedMonth, equals(DateTime(2026, 5)));
      expect(cubit.state.monthlyConsistencyRate, equals(0));
    });

    test('emits failure when streak use case fails', () async {
      const failure = Failure.localFailure(message: 'Database error');
      when(() => mockGetStreaksUseCase(any()))
          .thenAnswer((_) async => const Left(failure));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.failureOption, equals(const Some(failure)));
    });

    test('emits failure when qualifying periods use case fails', () async {
      const failure = Failure.localFailure(message: 'Query error');
      when(() => mockGetQualifyingPeriodsUseCase(any()))
          .thenAnswer((_) async => const Left(failure));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.failureOption, equals(const Some(failure)));
    });

    test('reloads reactively when transaction stream emits', () async {
      final cubit = buildCubit();
      await cubit.load();

      clearInteractions(mockGetStreaksUseCase);
      clearInteractions(mockGetQualifyingPeriodsUseCase);

      transactionsController.add(const Right([]));
      await pumpEventQueue();

      verify(() => mockGetStreaksUseCase(any())).called(1);
      verify(() => mockGetQualifyingPeriodsUseCase(any())).called(1);
    });
  });
}
