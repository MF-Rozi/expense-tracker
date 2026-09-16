import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Fullscreen custom range picker in the Financial Atelier style:
/// a calendar with a month/year dropdown (tap the header to jump to a
/// year), prev/next month chevrons, and a two-tap range selection.
///
/// Pops with a [DateTimeRange] (start at midnight, end at 23:59:59.999)
/// or null when dismissed.
class CustomRangePickerPage extends StatefulWidget {
  const CustomRangePickerPage({super.key});

  @override
  State<CustomRangePickerPage> createState() => _CustomRangePickerPageState();
}

class _CustomRangePickerPageState extends State<CustomRangePickerPage> {
  static const _primary = Color(0xFF00113A);
  static const _surface = Color(0xFFF8F9FA);
  static const _onSurface = Color(0xFF191C1D);
  static const _muted = Color(0xFF757682);

  DateTime? _start;
  DateTime? _end;
  late DateTime _displayedMonth;

  bool get _rangeComplete => _start != null && _end != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildRangeDisplay(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildMonthYearDropdown(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: _buildDayGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hand-built day grid: one dropdown + chevrons only — the built-in
  /// CalendarDatePicker's own header would duplicate them.
  Widget _buildDayGrid() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final leadingBlanks = firstDay.weekday % 7; // Sunday-first grid
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final cells = <Widget>[
      for (final weekday in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
        Center(
          child: Text(
            weekday,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
        ),
    ];

    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isSelectable = !date.isAfter(todayDate);
      final isStart = _start == date;
      final isEnd = _end == date;
      final isInRange = _start != null &&
          _end != null &&
          date.isAfter(_start!) &&
          date.isBefore(_end!);
      final isToday = date == todayDate && !isStart && !isEnd;

      cells.add(
        GestureDetector(
          onTap: isSelectable ? () => _onDateChanged(date) : null,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isStart || isEnd
                      ? _primary
                      : isInRange
                          ? _primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                  shape:
                      isStart || isEnd ? BoxShape.circle : BoxShape.rectangle,
                  border: isToday && !isStart && !isEnd && isSelectable
                      ? Border.all(color: _primary)
                      : null,
                  borderRadius:
                      isStart || isEnd ? null : BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isStart || isEnd ? FontWeight.w700 : FontWeight.w500,
                      color: isStart || isEnd
                          ? Colors.white
                          : isSelectable
                              ? _onSurface
                              : _muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: cells.take(7).toList()),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: cells.skip(7).toList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            color: _onSurface,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          TextButton(
            onPressed: _rangeComplete ? _save : null,
            style: TextButton.styleFrom(
              backgroundColor: _rangeComplete ? _primary : Colors.transparent,
              foregroundColor: _rangeComplete ? Colors.white : _muted,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              shape: const StadiumBorder(),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeDisplay() {
    String label;
    if (_start == null) {
      label = 'Pick a start date';
    } else if (_end == null) {
      label = '${_shortDate(_start!)} – …';
    } else {
      label = '${_shortDate(_start!)} – ${_shortDate(_end!)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select period',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: _muted,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearDropdown() {
    final monthLabel = DateFormat('MMMM yyyy').format(_displayedMonth);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showYearGrid,
            child: Row(
              children: [
                Text(
                  monthLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 22,
                  color: _onSurface,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
            ),
          ],
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  void _showYearGrid() {
    final years = List.generate(36, (index) => 2000 + index); // 2000..2035
    final currentYear = DateTime.now().year;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                'Select year',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.4,
                ),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isCurrentYear = year == currentYear;
                  final isSelectedYear = year == _displayedMonth.year;
                  return Padding(
                    padding: const EdgeInsets.all(6),
                    child: Material(
                      color: isSelectedYear
                          ? _primary.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          setState(() {
                            _displayedMonth = DateTime(
                              year,
                              _displayedMonth.month,
                            );
                          });
                        },
                        child: Center(
                          child: Text(
                            '$year',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: isCurrentYear || isSelectedYear
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isCurrentYear ? _primary : _onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDateChanged(DateTime picked) {
    final day = DateTime(picked.year, picked.month, picked.day);
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        // Fresh selection.
        _start = day;
        _end = null;
      } else if (!day.isBefore(_start!)) {
        _end = day;
      } else {
        // Tapped an earlier day — restart the range from it.
        _start = day;
      }
    });
  }

  void _save() {
    if (!_rangeComplete) return;
    Navigator.of(context).pop(
      DateTimeRange(
        start: DateTime(_start!.year, _start!.month, _start!.day),
        end: DateTime(
          _end!.year,
          _end!.month,
          _end!.day,
          23,
          59,
          59,
          999,
        ),
      ),
    );
  }

  String _shortDate(DateTime date) => DateFormat('MMM d').format(date);
}
