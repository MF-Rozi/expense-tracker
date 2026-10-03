import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_card.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_config_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildCard({
    required Streak streak,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: StreakCard(
          streak: streak,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  testWidgets(
    'active streak renders "N Day Streak" with correct milestone subtitle '
    'and progress fraction',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 5,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(buildCard(streak: streak));

      expect(find.text('5 Day Streak'), findsOneWidget);
      expect(find.text('2 days to next milestone'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(5 / 7, 0.001));
    },
  );

  testWidgets(
    'active streak with 1 day remaining uses singular "day"',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 6,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.9,
      );

      await tester.pumpWidget(buildCard(streak: streak));

      expect(find.text('6 Day Streak'), findsOneWidget);
      expect(find.text('1 day to next milestone'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(6 / 7, 0.001));
    },
  );

  testWidgets(
    'at-risk state renders the risk subtitle',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 5,
        status: StreakStatus.atRisk,
        daysUntilBreak: 1,
        nextMilestone: 7,
        consistencyRate: 0.7,
      );

      await tester.pumpWidget(buildCard(streak: streak));

      expect(find.text('5 Day Streak'), findsOneWidget);
      expect(
        find.text('At risk! Log today to keep your streak'),
        findsOneWidget,
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(5 / 7, 0.001));
    },
  );

  testWidgets(
    'warming-up state renders warming framing (Covers AE3 at widget level)',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 2,
        status: StreakStatus.warmingUp,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.5,
      );

      await tester.pumpWidget(buildCard(streak: streak));

      // Renders warming framing instead of celebrated streak
      expect(find.text('Warming Up'), findsOneWidget);
      expect(find.text('2 Day Streak'), findsNothing);
      expect(
        find.text('Warming up · Keep logging to activate your streak'),
        findsOneWidget,
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(2 / 7, 0.001));
    },
  );

  testWidgets(
    'empty streak hides the card entirely',
    (tester) async {
      await tester.pumpWidget(buildCard(streak: const Streak.empty()));

      expect(find.byType(StreakCard), findsOneWidget);
      expect(find.textContaining('Streak'), findsNothing);
      expect(find.textContaining('Warming'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'tap calls onTap callback when provided',
    (tester) async {
      var tapped = false;
      const streak = Streak(
        type: StreakType.tracking,
        length: 4,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(
        buildCard(
          streak: streak,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(StreakCard));
      await tester.pump();

      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'long-press calls onLongPress callback when provided',
    (tester) async {
      var longPressed = false;
      const streak = Streak(
        type: StreakType.tracking,
        length: 4,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(
        buildCard(
          streak: streak,
          onLongPress: () => longPressed = true,
        ),
      );

      await tester.longPress(find.byType(StreakCard));
      await tester.pump();

      expect(longPressed, isTrue);
    },
  );

  testWidgets(
    'tap navigates to /streaks by default',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 4,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: StreakCard(streak: streak),
            ),
          ),
          GoRoute(
            path: '/streaks',
            builder: (context, state) => const Scaffold(
              body: Text('Target Streaks Page'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.tap(find.byType(StreakCard));
      await tester.pumpAndSettle();

      expect(find.text('Target Streaks Page'), findsOneWidget);
    },
  );

  testWidgets(
    'long-press opens StreakConfigSheet by default',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 4,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakCard(streak: streak),
          ),
        ),
      );

      await tester.longPress(find.byType(StreakCard));
      await tester.pumpAndSettle();

      expect(find.byType(StreakConfigSheet), findsOneWidget);
      expect(find.text('Streak Settings'), findsOneWidget);
    },
  );
}
