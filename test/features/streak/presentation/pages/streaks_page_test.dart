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
      ),
    ).thenAnswer((_) async {});
    when(mockCubit.previousMonth).thenAnswer((_) async {});
    when(mockCubit.nextMonth).thenAnswer((_) async {});
  });

  Widget buildStreaksPage({StreakCubit? cubit}) {
    return MaterialApp(
      home: StreaksPage(cubit: cubit ?? mockCubit),
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
