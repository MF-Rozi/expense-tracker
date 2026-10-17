import 'package:equatable/equatable.dart';

/// Abstraction for a discrete time period in streak computations.
///
/// Can represent daily periods ([StreakDay]) or monthly periods
/// ([StreakMonth]).
sealed class StreakPeriod extends Equatable
    implements Comparable<StreakPeriod> {
  const StreakPeriod();

  factory StreakPeriod.day(DateTime date) => StreakDay.fromDateTime(date);
  factory StreakPeriod.month(int year, int month) => StreakMonth(year, month);

  /// Number of periods from [other] to this period (`this - other`).
  ///
  /// Positive if this period is after [other], zero if identical,
  /// negative if before.
  int differenceInPeriods(StreakPeriod other);

  /// The subsequent period.
  StreakPeriod next();

  /// The previous period.
  StreakPeriod previous();

  /// Number of elapsed periods within the enclosing container
  /// (e.g. Day of the month for [StreakDay], month of the year
  /// for [StreakMonth]).
  int get elapsedInContainer;

  /// Whether [other] belongs to the same enclosing container
  /// (e.g. same year and month for [StreakDay], same year for [StreakMonth]).
  bool isInSameContainer(StreakPeriod other);
}

/// A calendar day period, stripped of time and timezone offsets.
class StreakDay extends StreakPeriod {
  StreakDay(DateTime date)
      : year = date.year,
        month = date.month,
        day = date.day;

  StreakDay.fromDateTime(DateTime date)
      : year = date.year,
        month = date.month,
        day = date.day;

  const StreakDay.fromYmd(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  @override
  int differenceInPeriods(StreakPeriod other) {
    if (other is! StreakDay) {
      throw ArgumentError(
        'Cannot compare StreakDay with ${other.runtimeType}',
      );
    }
    // Using UTC dates ensures exact 24-hour difference per calendar day,
    // completely immune to local DST transitions.
    final d1 = DateTime.utc(year, month, day);
    final d2 = DateTime.utc(other.year, other.month, other.day);
    return d1.difference(d2).inDays;
  }

  @override
  StreakDay next() {
    final nextDate = DateTime.utc(year, month, day + 1);
    return StreakDay.fromYmd(nextDate.year, nextDate.month, nextDate.day);
  }

  @override
  StreakDay previous() {
    final prevDate = DateTime.utc(year, month, day - 1);
    return StreakDay.fromYmd(prevDate.year, prevDate.month, prevDate.day);
  }

  @override
  int get elapsedInContainer => day;

  @override
  bool isInSameContainer(StreakPeriod other) {
    if (other is! StreakDay) return false;
    return other.year == year && other.month == month;
  }

  @override
  int compareTo(StreakPeriod other) {
    if (other is! StreakDay) {
      throw ArgumentError(
        'Cannot compare StreakDay with ${other.runtimeType}',
      );
    }
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  List<Object?> get props => [year, month, day];
}

/// A calendar month period, identified by year and month.
class StreakMonth extends StreakPeriod {
  const StreakMonth(this.year, this.month)
      : assert(month >= 1 && month <= 12, 'Month must be between 1 and 12');

  StreakMonth.fromDateTime(DateTime date)
      : year = date.year,
        month = date.month;

  final int year;
  final int month;

  @override
  int differenceInPeriods(StreakPeriod other) {
    if (other is! StreakMonth) {
      throw ArgumentError(
        'Cannot compare StreakMonth with ${other.runtimeType}',
      );
    }
    return (year * 12 + month) - (other.year * 12 + other.month);
  }

  @override
  StreakMonth next() {
    if (month == 12) {
      return StreakMonth(year + 1, 1);
    }
    return StreakMonth(year, month + 1);
  }

  @override
  StreakMonth previous() {
    if (month == 1) {
      return StreakMonth(year - 1, 12);
    }
    return StreakMonth(year, month - 1);
  }

  @override
  int get elapsedInContainer => month;

  @override
  bool isInSameContainer(StreakPeriod other) {
    if (other is! StreakMonth) return false;
    return other.year == year;
  }

  @override
  int compareTo(StreakPeriod other) {
    if (other is! StreakMonth) {
      throw ArgumentError(
        'Cannot compare StreakMonth with ${other.runtimeType}',
      );
    }
    if (year != other.year) return year.compareTo(other.year);
    return month.compareTo(other.month);
  }

  @override
  List<Object?> get props => [year, month];
}
