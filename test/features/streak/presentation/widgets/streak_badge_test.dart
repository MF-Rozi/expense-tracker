import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required Streak streak,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: StreakBadge(
          streak: streak,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets(
    'renders flame icon and streak count when active',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 5,
        status: StreakStatus.active,
        daysUntilBreak: 2,
        nextMilestone: 7,
        consistencyRate: 0.8,
      );

      await tester.pumpWidget(buildSubject(streak: streak));

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    },
  );

  testWidgets(
    'renders 0 with muted style when streak is empty',
    (tester) async {
      const streak = Streak(
        type: StreakType.tracking,
        length: 0,
        status: StreakStatus.none,
        daysUntilBreak: 0,
        nextMilestone: 3,
        consistencyRate: 0,
      );

      await tester.pumpWidget(buildSubject(streak: streak));

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    },
  );

  testWidgets('renders at-risk styling when streak is at risk', (tester) async {
    const streak = Streak(
      type: StreakType.tracking,
      length: 8,
      status: StreakStatus.atRisk,
      daysUntilBreak: 0,
      nextMilestone: 14,
      consistencyRate: 0.9,
    );

    await tester.pumpWidget(buildSubject(streak: streak));

    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('triggers onTap callback when pressed', (tester) async {
    var tapped = false;
    const streak = Streak(
      type: StreakType.tracking,
      length: 3,
      status: StreakStatus.active,
      daysUntilBreak: 1,
      nextMilestone: 7,
      consistencyRate: 0.7,
    );

    await tester.pumpWidget(
      buildSubject(
        streak: streak,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(StreakBadge));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
