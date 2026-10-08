import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_cubit.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_state.dart';
import 'package:expense_tracker/features/streak/presentation/pages/streaks_page.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/milestone_progress.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_calendar.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_config_sheet.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockStreakCubit extends MockCubit<StreakState> implements StreakCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(StreakType.tracking);
  });

  late MockStreakCubit mockCubit;

  final fixedMonth = DateTime(2026, 4);

  const tStreak = Streak(
    type: StreakType.tracking,
    length: 14,
    status: StreakStatus.active,
    daysUntilBreak: 3,
    nextMilestone: 21,
    consistencyRate: 0.8,
  );

  final tQualifyingDays = {
    DateTime(2026, 4),
    DateTime(2026, 4, 2),
    DateTime(2026, 4, 3),
  };

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    mockCubit = MockStreakCubit();

    when(
      () => mockCubit.load(
        month: any(named: 'month'),
        showLoading: any(named: 'showLoading'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockCubit.selectType(any())).thenAnswer((_) async {});
    when(mockCubit.previousMonth).thenAnswer((_) async {});
    when(mockCubit.nextMonth).thenAnswer((_) async {});
  });

  Widget buildStreaksPage({StreakCubit? cubit, StreakType? initialType}) {
    return MaterialApp(
      home: StreaksPage(
        cubit: cubit ?? mockCubit,
        initialType: initialType,
      ),
    );
  }

  group('StreaksPage', () {
    testWidgets('renders loading spinner when initial state is loading',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          selectedMonth: fixedMonth,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders hero, calendar, consistency card, and milestones',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          streak: tStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: tQualifyingDays,
          monthlyConsistencyRate: 0.2,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      expect(find.byType(StreakHero), findsOneWidget);
      expect(find.byType(StreakCalendar), findsOneWidget);
      expect(find.byType(StreakConsistencyCard), findsOneWidget);
      expect(find.byType(MilestoneProgress), findsOneWidget);

      expect(find.text('14 Day Streak'), findsOneWidget);
      expect(find.text('April 2026'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('Upcoming Milestones'), findsOneWidget);
    });

    testWidgets('renders type chips for all active streak types',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          streak: tStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: tQualifyingDays,
          monthlyConsistencyRate: 0.2,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      expect(
        find.byKey(const Key('streak_type_chip_tracking')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('streak_type_chip_noSpend')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('streak_type_chip_appOpen')),
        findsOneWidget,
      );
    });

    testWidgets('tapping a type chip calls selectType on cubit',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          streak: tStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: tQualifyingDays,
          monthlyConsistencyRate: 0.2,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      await tester.tap(find.byKey(const Key('streak_type_chip_noSpend')));
      verify(() => mockCubit.selectType(StreakType.noSpend)).called(1);

      await tester.tap(find.byKey(const Key('streak_type_chip_appOpen')));
      verify(() => mockCubit.selectType(StreakType.appOpen)).called(1);
    });

    testWidgets(
        'switching type switches hero, calendar marks, and consistency source',
        (tester) async {
      const appOpenStreak = Streak(
        type: StreakType.appOpen,
        length: 7,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 14,
        consistencyRate: 0.7,
      );

      final appOpenDays = {
        DateTime(2026, 4, 5),
        DateTime(2026, 4, 12),
      };

      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          type: StreakType.appOpen,
          streak: appOpenStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: appOpenDays,
          monthlyConsistencyRate: 0.7,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      expect(find.text('7 Day Streak'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);

      final appOpenChip = tester.widget<ChoiceChip>(
        find.byKey(const Key('streak_type_chip_appOpen')),
      );
      expect(appOpenChip.selected, isTrue);
    });

    testWidgets(
        'long-press on an app-open element deep-links to its config section',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          type: StreakType.appOpen,
          streak: const Streak(
            type: StreakType.appOpen,
            length: 3,
            status: StreakStatus.active,
            daysUntilBreak: 3,
            nextMilestone: 7,
            consistencyRate: 0.5,
          ),
          selectedMonth: fixedMonth,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      // Long press the app-open type chip
      await tester.longPress(find.byKey(const Key('streak_type_chip_appOpen')));
      await tester.pumpAndSettle();

      expect(find.byType(StreakConfigSheet), findsOneWidget);
      expect(find.text('App-Open Cadence'), findsOneWidget);
    });

    testWidgets('types without records yet render empty states, not zeros',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          type: StreakType.noSpend,
          selectedMonth: fixedMonth,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      // Hero should show empty headline, not "0 Day Streak"
      expect(find.text('No Active Streak'), findsOneWidget);
      expect(find.text('0 Day Streak'), findsNothing);

      // Consistency should show "—" and not "0%"
      expect(find.text('—'), findsOneWidget);
      expect(find.text('0%'), findsNothing);
      expect(find.text('No activity recorded yet'), findsOneWidget);
    });

    testWidgets('initialType parameter selects requested type on creation',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          type: StreakType.appOpen,
          selectedMonth: fixedMonth,
        ),
      );

      await tester.pumpWidget(
        buildStreaksPage(initialType: StreakType.appOpen),
      );

      verify(() => mockCubit.selectType(StreakType.appOpen)).called(1);
    });

    testWidgets('calendar chevrons call previousMonth and nextMonth',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          streak: tStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: tQualifyingDays,
          monthlyConsistencyRate: 0.2,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      await tester.tap(find.byTooltip('Previous month'));
      verify(mockCubit.previousMonth).called(1);

      await tester.tap(find.byTooltip('Next month'));
      verify(mockCubit.nextMonth).called(1);
    });

    testWidgets('tapping configure action opens StreakConfigSheet',
        (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          streak: tStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: tQualifyingDays,
          monthlyConsistencyRate: 0.2,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      await tester.tap(find.byTooltip('Configure Streak'));
      await tester.pumpAndSettle();

      expect(find.byType(StreakConfigSheet), findsOneWidget);
    });

    testWidgets('long pressing hero opens StreakConfigSheet', (tester) async {
      when(() => mockCubit.state).thenReturn(
        StreakState(
          isLoading: false,
          streak: tStreak,
          selectedMonth: fixedMonth,
          qualifyingDays: tQualifyingDays,
          monthlyConsistencyRate: 0.2,
        ),
      );

      await tester.pumpWidget(buildStreaksPage());

      await tester.longPress(find.byType(StreakHero));
      await tester.pumpAndSettle();

      expect(find.byType(StreakConfigSheet), findsOneWidget);
    });
  });
}
