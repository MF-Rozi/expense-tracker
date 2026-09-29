import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakDay', () {
    test('creates from DateTime and strips time components', () {
      final dt = DateTime(2026, 9, 28, 14, 30, 45, 123);
      final period = StreakDay.fromDateTime(dt);

      expect(period.year, 2026);
      expect(period.month, 9);
      expect(period.day, 28);
      expect(period.elapsedInContainer, 28);
      expect(period.toDateTime(), DateTime(2026, 9, 28));
    });

    test('calculates differenceInPeriods accurately between days', () {
      const day1 = StreakDay.fromYmd(2026, 9, 1);
      const day3 = StreakDay.fromYmd(2026, 9, 3);

      expect(day3.differenceInPeriods(day1), 2);
      expect(day1.differenceInPeriods(day3), -2);
      expect(day1.differenceInPeriods(day1), 0);
    });

    test('next and previous step one calendar day', () {
      const day = StreakDay.fromYmd(2026, 2, 28);
      final nextDay = day.next();
      expect(nextDay, const StreakDay.fromYmd(2026, 3, 1));
      expect(nextDay.previous(), day);
    });

    test('isInSameContainer checks same year and month', () {
      const day1 = StreakDay.fromYmd(2026, 9, 5);
      const day2 = StreakDay.fromYmd(2026, 9, 28);
      const nextMonth = StreakDay.fromYmd(2026, 10, 1);
      const nextYear = StreakDay.fromYmd(2027, 9, 5);

      expect(day1.isInSameContainer(day2), isTrue);
      expect(day1.isInSameContainer(nextMonth), isFalse);
      expect(day1.isInSameContainer(nextYear), isFalse);
    });

    test('compareTo orders dates chronologically', () {
      const day1 = StreakDay.fromYmd(2026, 8, 31);
      const day2 = StreakDay.fromYmd(2026, 9, 1);
      const day3 = StreakDay.fromYmd(2026, 9, 2);

      expect(day1.compareTo(day2), isNegative);
      expect(day2.compareTo(day1), isPositive);
      expect(day2.compareTo(day2), isZero);

      final list = [day3, day1, day2]..sort();
      expect(list, [day1, day2, day3]);
    });

    test('throws ArgumentError when comparing with different period types', () {
      const day = StreakDay.fromYmd(2026, 9, 1);
      const month = StreakMonth(2026, 9);

      expect(
        () => day.differenceInPeriods(month),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => day.compareTo(month),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'DST and timezone safety: difference is exact across 23/25 hour days',
        () {
      // March DST transition in Europe/US (23 hours)
      const march28 = StreakDay.fromYmd(2026, 3, 28);
      const march29 = StreakDay.fromYmd(2026, 3, 29);
      const march30 = StreakDay.fromYmd(2026, 3, 30);

      expect(march29.differenceInPeriods(march28), 1);
      expect(march30.differenceInPeriods(march28), 2);

      // October DST fall back transition (25 hours)
      const oct24 = StreakDay.fromYmd(2026, 10, 24);
      const oct25 = StreakDay.fromYmd(2026, 10, 25);
      const oct26 = StreakDay.fromYmd(2026, 10, 26);

      expect(oct25.differenceInPeriods(oct24), 1);
      expect(oct26.differenceInPeriods(oct24), 2);
    });
  });

  group('StreakMonth', () {
    test('creates from DateTime and asserts valid month', () {
      final dt = DateTime(2026, 9, 15);
      final month = StreakMonth.fromDateTime(dt);

      expect(month.year, 2026);
      expect(month.month, 9);
      expect(month.elapsedInContainer, 9);

      expect(
        () => StreakMonth(2026, 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => StreakMonth(2026, 13),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
        'calculates differenceInPeriods across months and year boundaries',
        () {
      const dec2025 = StreakMonth(2025, 12);
      const jan2026 = StreakMonth(2026, 1);
      const mar2026 = StreakMonth(2026, 3);

      expect(jan2026.differenceInPeriods(dec2025), 1);
      expect(mar2026.differenceInPeriods(dec2025), 3);
      expect(dec2025.differenceInPeriods(jan2026), -1);
    });

    test('next and previous step across year boundary', () {
      const dec = StreakMonth(2025, 12);
      final jan = dec.next();
      expect(jan, const StreakMonth(2026, 1));
      expect(jan.previous(), dec);
    });

    test('isInSameContainer checks same year', () {
      const jan2026 = StreakMonth(2026, 1);
      const dec2026 = StreakMonth(2026, 12);
      const jan2027 = StreakMonth(2027, 1);

      expect(jan2026.isInSameContainer(dec2026), isTrue);
      expect(jan2026.isInSameContainer(jan2027), isFalse);
    });

    test('compareTo orders months chronologically', () {
      const m1 = StreakMonth(2025, 12);
      const m2 = StreakMonth(2026, 1);
      const m3 = StreakMonth(2026, 2);

      expect(m1.compareTo(m2), isNegative);
      expect(m2.compareTo(m1), isPositive);

      final list = [m3, m1, m2]..sort();
      expect(list, [m1, m2, m3]);
    });
  });
}
