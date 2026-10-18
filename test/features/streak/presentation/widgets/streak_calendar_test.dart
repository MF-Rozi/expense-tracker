import 'package:expense_tracker/features/streak/presentation/widgets/streak_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final fixedMonth = DateTime(2026, 4);
  final fixedToday = DateTime(2026, 4, 15);

  Widget buildCalendar({
    required Set<DateTime> qualifyingDays,
    VoidCallback? onPreviousMonth,
    VoidCallback? onNextMonth,
    DateTime? referenceDate,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreakCalendar(
                selectedMonth: fixedMonth,
                qualifyingDays: qualifyingDays,
                onPreviousMonth: onPreviousMonth ?? () {},
                onNextMonth: onNextMonth ?? () {},
                referenceDate: referenceDate ?? fixedToday,
              ),
              const StreakConsistencyCard(consistencyRate: 0.85),
            ],
          ),
        ),
      ),
    );
  }

  group('StreakCalendar & StreakConsistencyCard', () {
    testWidgets('renders month header, weekdays, and consistency card',
        (tester) async {
      await tester.pumpWidget(
        buildCalendar(
          qualifyingDays: {
            DateTime(2026, 4),
            DateTime(2026, 4, 2),
          },
        ),
      );

      expect(find.text('April 2026'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      expect(find.text('CONSISTENCY'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Completion rate this month'), findsOneWidget);
    });

    testWidgets('calls onPreviousMonth and onNextMonth on button taps',
        (tester) async {
      var prevCalled = false;
      var nextCalled = false;

      await tester.pumpWidget(
        buildCalendar(
          qualifyingDays: {},
          onPreviousMonth: () => prevCalled = true,
          onNextMonth: () => nextCalled = true,
        ),
      );

      await tester.tap(find.byTooltip('Previous month'));
      expect(prevCalled, isTrue);

      await tester.tap(find.byTooltip('Next month'));
      expect(nextCalled, isTrue);
    });

    testWidgets('highlights today and qualifying days with appropriate styling',
        (tester) async {
      await tester.pumpWidget(
        buildCalendar(
          qualifyingDays: {
            DateTime(2026, 4, 15), // Today is qualified
            DateTime(2026, 4, 10), // Another day qualified
          },
        ),
      );

      // Day 15 should have white text (on primary) because today is qualified
      final day15Text = tester.widget<Text>(find.text('15'));
      expect(day15Text.style?.color, equals(Colors.white));

      // Day 10 should have dark green text (on secondary container)
      final day10Text = tester.widget<Text>(find.text('10'));
      expect(day10Text.style?.color, equals(const Color(0xFF217128)));
    });

    testWidgets('highlights today with primary border when not qualifying',
        (tester) async {
      await tester.pumpWidget(
        buildCalendar(
          qualifyingDays: {
            DateTime(2026, 4, 10), // Only day 10 qualified
          },
        ),
      );

      // Day 15 is today and not qualified -> primary text color
      final day15Text = tester.widget<Text>(find.text('15'));
      expect(day15Text.style?.color, equals(const Color(0xFF00113A)));
    });
  });
}
