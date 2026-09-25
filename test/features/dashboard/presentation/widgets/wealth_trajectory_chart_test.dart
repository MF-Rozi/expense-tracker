import 'package:expense_tracker/features/dashboard/domain/entities/wealth_trajectory.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/wealth_trajectory_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget(WealthTrajectory? trajectory) {
    return MaterialApp(
      home: Scaffold(
        body: WealthTrajectoryChart(trajectory: trajectory),
      ),
    );
  }

  testWidgets('renders headline, dynamic growth subtitle, and 5 month labels',
      (tester) async {
    final trajectory = WealthTrajectory(
      points: [
        TrajectoryPoint(
          month: DateTime(2026, 5),
          netWorth: 1000,
          isCurrentMonth: false,
        ),
        TrajectoryPoint(
          month: DateTime(2026, 6),
          netWorth: 2000,
          isCurrentMonth: false,
        ),
        TrajectoryPoint(
          month: DateTime(2026, 7),
          netWorth: 3000,
          isCurrentMonth: false,
        ),
        TrajectoryPoint(
          month: DateTime(2026, 8),
          netWorth: 4000,
          isCurrentMonth: false,
        ),
        TrajectoryPoint(
          month: DateTime(2026, 9),
          netWorth: 5000,
          isCurrentMonth: true,
        ),
      ],
      growthPercentage: 25,
      headlineDescription: 'Your net worth increased by 25.0% this month.',
    );

    await tester.pumpWidget(buildWidget(trajectory));

    expect(find.text('Wealth Trajectory'), findsOneWidget);
    expect(
      find.text('Your net worth increased by 25.0% this month.'),
      findsOneWidget,
    );

    expect(find.text('May'), findsOneWidget);
    expect(find.text('Jun'), findsOneWidget);
    expect(find.text('Jul'), findsOneWidget);
    expect(find.text('Aug'), findsOneWidget);
    expect(find.text('Sep'), findsOneWidget);
  });

  testWidgets('handles null or empty trajectory gracefully', (tester) async {
    await tester.pumpWidget(buildWidget(null));

    expect(find.text('Wealth Trajectory'), findsOneWidget);
    expect(find.text('No transaction data yet.'), findsOneWidget);
  });
}
