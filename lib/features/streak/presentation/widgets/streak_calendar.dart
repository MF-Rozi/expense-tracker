import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Bento-style month calendar marking qualifying days and today's status.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({
    required this.selectedMonth,
    required this.qualifyingDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    super.key,
    this.referenceDate,
  });

  final DateTime selectedMonth;
  final Set<DateTime> qualifyingDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final DateTime? referenceDate;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final now = referenceDate ?? DateTime.now();
    final firstDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month);
    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    // Monday is 1, Sunday is 7 in Dart DateTime.
    final leadingEmptyCells = (firstDayOfMonth.weekday - 1) % 7;
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00113A),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: const Color(0xFF757682),
                    tooltip: 'Previous month',
                    onPressed: onPreviousMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: const Color(0xFF757682),
                    tooltip: 'Next month',
                    onPressed: onNextMonth,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF757682),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(rowCount, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: List.generate(7, (colIndex) {
                    final cellIndex = rowIndex * 7 + colIndex;
                    final dayNumber = cellIndex - leadingEmptyCells + 1;

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox());
                    }

                    final cellDate = DateTime(
                      selectedMonth.year,
                      selectedMonth.month,
                      dayNumber,
                    );
                    final isQualifying = qualifyingDays.contains(cellDate);
                    final isToday = cellDate.year == now.year &&
                        cellDate.month == now.month &&
                        cellDate.day == now.day;
                    final isFuture = cellDate.isAfter(now);

                    return Expanded(
                      child: Center(
                        child: _DayCell(
                          dayNumber: dayNumber,
                          isQualifying: isQualifying,
                          isToday: isToday,
                          isFuture: isFuture,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.isQualifying,
    required this.isToday,
    required this.isFuture,
  });

  final int dayNumber;
  final bool isQualifying;
  final bool isToday;
  final bool isFuture;

  static const _secondaryContainer = Color(0xFFA0F399);
  static const _onSecondaryContainer = Color(0xFF217128);
  static const _primary = Color(0xFF00113A);

  @override
  Widget build(BuildContext context) {
    if (isToday && isQualifying) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNumber',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (isQualifying) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(
            color: _onSecondaryContainer.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNumber',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _onSecondaryContainer,
          ),
        ),
      );
    }

    if (isToday) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _primary,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$dayNumber',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
      );
    }

    return SizedBox(
      width: 34,
      height: 34,
      child: Center(
        child: Text(
          '$dayNumber',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isFuture
                ? const Color(0xFFB0B2B8)
                : const Color(0xFF444650),
          ),
        ),
      ),
    );
  }
}

/// Bento-style card displaying the monthly consistency completion rate.
class StreakConsistencyCard extends StatelessWidget {
  const StreakConsistencyCard({
    required this.consistencyRate,
    this.hasData = true,
    super.key,
  });

  final double consistencyRate;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final percentage = (consistencyRate * 100).round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CONSISTENCY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00113A),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasData ? '$percentage%' : '—',
            style: GoogleFonts.manrope(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF00113A),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasData ? 'Completion rate this month' : 'No activity recorded yet',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF757682),
            ),
          ),
        ],
      ),
    );
  }
}
