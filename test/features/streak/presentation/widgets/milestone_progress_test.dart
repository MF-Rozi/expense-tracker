import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/milestone_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildMilestones(Streak streak) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MilestoneProgress(streak: streak),
        ),
      ),
    );
  }

  group('MilestoneProgress', () {
    testWidgets('renders next upcoming milestones from ladder with days left',
        (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 14,
        status: StreakStatus.active,
        daysUntilBreak: 3,
        nextMilestone: 21,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(buildMilestones(streak));

      expect(find.text('Upcoming Milestones'), findsOneWidget);
      expect(find.text('21 Day Routine'), findsOneWidget);
      expect(find.text('7 days left'), findsOneWidget);

      expect(find.text('Monthly Master'), findsOneWidget);
      expect(find.text('16 days left'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('renders singular "1 day left" when 1 day remains',
        (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 6,
        status: StreakStatus.active,
        daysUntilBreak: 3,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(buildMilestones(streak));

      expect(find.text('7 Day Habit'), findsOneWidget);
      expect(find.text('1 day left'), findsOneWidget);
    });

    testWidgets('advances to next year milestone when length reaches 365',
        (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 365,
        status: StreakStatus.active,
        daysUntilBreak: 3,
        nextMilestone: 730,
        consistencyRate: 0.95,
      );

      await tester.pumpWidget(buildMilestones(streak));

      expect(find.text('730 Day Milestone'), findsOneWidget);
      expect(find.text('365 days left'), findsOneWidget);
    });
  });
}
