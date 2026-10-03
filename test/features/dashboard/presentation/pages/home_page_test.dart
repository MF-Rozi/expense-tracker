import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_cubit.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/home_page.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/wealth_trajectory_chart.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  late MockDashboardCubit mockCubit;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    mockCubit = MockDashboardCubit();
    when(() => mockCubit.loadDashboardData())
        .thenAnswer((_) async {});
  });

  Widget buildHomePage() {
    return MaterialApp(
      home: BlocProvider<DashboardCubit>.value(
        value: mockCubit,
        child: const HomePage(),
      ),
    );
  }

  testWidgets(
    'renders StreakCard between SummaryCard and WealthTrajectoryChart '
    'when streak is not empty',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 5,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      when(() => mockCubit.state).thenReturn(
        const DashboardState(
          isLoading: false,
          streak: streak,
        ),
      );

      await tester.pumpWidget(buildHomePage());

      expect(find.byType(SummaryCard), findsOneWidget);
      expect(find.byType(StreakCard), findsOneWidget);
      expect(find.byType(WealthTrajectoryChart), findsOneWidget);

      final summaryTop = tester.getTopLeft(find.byType(SummaryCard)).dy;
      final streakTop = tester.getTopLeft(find.byType(StreakCard)).dy;
      final wealthTop =
          tester.getTopLeft(find.byType(WealthTrajectoryChart)).dy;

      expect(summaryTop < streakTop, isTrue);
      expect(streakTop < wealthTop, isTrue);
    },
  );

  testWidgets(
    'omits StreakCard when streak is empty',
    (tester) async {
      when(() => mockCubit.state).thenReturn(
        const DashboardState(isLoading: false),
      );

      await tester.pumpWidget(buildHomePage());

      expect(find.byType(SummaryCard), findsOneWidget);
      expect(find.byType(StreakCard), findsNothing);
      expect(find.byType(WealthTrajectoryChart), findsOneWidget);
    },
  );
}
