import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildHero(Streak streak, {VoidCallback? onLongPress}) {
    return MaterialApp(
      home: Scaffold(
        body: StreakHero(
          streak: streak,
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  group('StreakHero', () {
    testWidgets('renders active status with plural headline', (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 14,
        status: StreakStatus.active,
        daysUntilBreak: 3,
        nextMilestone: 21,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(buildHero(streak));

      expect(find.text('14 Day Streak'), findsOneWidget);
      expect(find.text('MASTERING FINANCIAL DISCIPLINE'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('renders singular headline for 1 day streak', (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 1,
        status: StreakStatus.warmingUp,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.5,
      );

      await tester.pumpWidget(buildHero(streak));

      expect(find.text('1 Day Streak'), findsOneWidget);
      expect(find.text('WARMING UP • HABIT IN FORMATION'), findsOneWidget);
    });

    testWidgets('renders at risk subtitle when status is atRisk',
        (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 5,
        status: StreakStatus.atRisk,
        daysUntilBreak: 1,
        nextMilestone: 7,
        consistencyRate: 0.5,
      );

      await tester.pumpWidget(buildHero(streak));

      expect(find.text('AT RISK • LOG AN EXPENSE TODAY'), findsOneWidget);
    });

    testWidgets('renders broken subtitle when status is broken',
        (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 0,
        status: StreakStatus.broken,
        daysUntilBreak: 0,
        nextMilestone: 7,
        consistencyRate: 0,
      );

      await tester.pumpWidget(buildHero(streak));

      expect(find.text('No Active Streak'), findsOneWidget);
      expect(find.text('STREAK PAUSED • LOG TODAY TO RESUME'), findsOneWidget);
    });

    testWidgets('renders warming up when length is 0 and status warmingUp',
        (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 0,
        status: StreakStatus.warmingUp,
        daysUntilBreak: 0,
        nextMilestone: 7,
        consistencyRate: 0,
      );

      await tester.pumpWidget(buildHero(streak));

      expect(find.text('Warming Up'), findsOneWidget);
      expect(find.text('WARMING UP • HABIT IN FORMATION'), findsOneWidget);
    });

    testWidgets('triggers onLongPress callback', (tester) async {
      var pressed = false;
      const streak = Streak(
        type: StreakType.tracking,
        length: 5,
        status: StreakStatus.active,
        daysUntilBreak: 3,
        nextMilestone: 7,
        consistencyRate: 0.7,
      );

      await tester.pumpWidget(
        buildHero(streak, onLongPress: () => pressed = true),
      );

      await tester.longPress(find.byType(StreakHero));
      expect(pressed, isTrue);
    });
  });
}
