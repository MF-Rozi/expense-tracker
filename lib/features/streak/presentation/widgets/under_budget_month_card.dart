import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';
import 'package:expense_tracker/features/streak/domain/entities/under_budget_month_status.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Month-level card presenting under-budget status, in-progress preview,
/// and per-category overrun flags (R14, R17).
class UnderBudgetMonthCard extends StatelessWidget {
  const UnderBudgetMonthCard({
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    super.key,
    this.status,
    this.isOnTrack,
    this.overrunFlags = const [],
    this.referenceDate,
  });

  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final UnderBudgetMonthStatus? status;
  final bool? isOnTrack;
  final List<CategoryOverrunFlag> overrunFlags;
  final DateTime? referenceDate;

  static const _primary = Color(0xFF00113A);
  static const _secondary = Color(0xFF757682);
  static const _successBg = Color(0xFFA0F399);
  static const _successText = Color(0xFF217128);
  static const _errorBg = Color(0xFFFEE2E2);
  static const _errorText = Color(0xFF991B1B);
  static const _warningText = Color(0xFFB45309);
  static const _warningBg = Color(0xFFFEF3C7);

  String _buildExplanatoryNote({
    required bool hasBudget,
    required bool isCurrentMonth,
    required bool isPastMonth,
    required bool onTrack,
  }) {
    if (!hasBudget) {
      return 'Configure monthly envelope budgets to track your under-budget '
          'streak.';
    }
    if (isCurrentMonth) {
      if (onTrack) {
        return 'Mid-month spend is within your total monthly budget. '
            'Stay under until month-end to extend your streak!';
      }
      return 'Mid-month spend exceeds total monthly budget. '
          'Streak count is preserved until month-end.';
    }
    if (isPastMonth) {
      if (onTrack) {
        return 'Completed month met total budget goals and qualified for '
            'your streak.';
      }
      return 'Completed month exceeded total budget goals.';
    }
    return 'Future month.';
  }

  @override
  Widget build(BuildContext context) {
    final now = referenceDate ?? DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;
    final isPastMonth =
        DateTime(selectedMonth.year, selectedMonth.month).isBefore(
      DateTime(now.year, now.month),
    );

    final totalBudget = status?.totalBudget ?? 0.0;
    final totalSpent = status?.totalSpent ?? 0.0;
    final flags = overrunFlags.isNotEmpty
        ? overrunFlags
        : (status?.overrunFlags ?? const []);
    final onTrack = isOnTrack ??
        status?.isOnTrack ??
        (totalBudget > 0 && totalSpent <= totalBudget);
    final hasBudget = totalBudget > 0;

    final currencyFormatter = NumberFormat.simpleCurrency(decimalDigits: 0);
    final remainingFormatted = currencyFormatter.format(
      (totalBudget - totalSpent).clamp(0, double.infinity),
    );
    final exceededFormatted = currencyFormatter.format(
      (totalSpent - totalBudget).clamp(0, double.infinity),
    );

    return Container(
      key: const Key('under_budget_month_card'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('streak_calendar_prev_month'),
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: onPreviousMonth,
                color: _primary,
              ),
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              IconButton(
                key: const Key('streak_calendar_next_month'),
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: onNextMonth,
                color: _primary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Badge Row
          Row(
            children: [
              Container(
                key: const Key('under_budget_status_badge'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: !hasBudget
                      ? const Color(0xFFF3F4F6)
                      : onTrack
                          ? _successBg.withValues(alpha: 0.4)
                          : _errorBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      !hasBudget
                          ? Icons.info_outline_rounded
                          : onTrack
                              ? Icons.check_circle_outline_rounded
                              : Icons.warning_amber_rounded,
                      size: 16,
                      color: !hasBudget
                          ? _secondary
                          : onTrack
                              ? _successText
                              : _errorText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      !hasBudget
                          ? 'NO BUDGET SET'
                          : isCurrentMonth
                              ? (onTrack
                                  ? 'ON TRACK (PREVIEW)'
                                  : 'OFF TRACK (PREVIEW)')
                              : (onTrack ? 'QUALIFIED' : 'OVER BUDGET'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: !hasBudget
                            ? _secondary
                            : onTrack
                                ? _successText
                                : _errorText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Explanatory note
          Text(
            _buildExplanatoryNote(
              hasBudget: hasBudget,
              isCurrentMonth: isCurrentMonth,
              isPastMonth: isPastMonth,
              onTrack: onTrack,
            ),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _secondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Budget Numbers Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL SPENT',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(totalSpent),
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onTrack ? _primary : _errorText,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BUDGET TARGET',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(totalBudget),
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          if (hasBudget) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                key: const Key('under_budget_progress_bar'),
                value: totalBudget > 0
                    ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: const Color(0xFFF3F4F6),
                color: onTrack ? _successText : _errorText,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),

            // Remaining / Overrun caption
            Text(
              onTrack
                  ? '$remainingFormatted remaining'
                  : 'Exceeded by $exceededFormatted',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: onTrack ? _successText : _errorText,
              ),
            ),
          ],

          // Category Overruns Section (R17)
          if (flags.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: _warningText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Category Budget Overruns (${flags.length})',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _warningText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Individual categories exceeded their budgets, '
              'but total month qualifies.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _secondary,
              ),
            ),
            const SizedBox(height: 8),
            ...flags.map((flag) {
              final spentFmt = currencyFormatter.format(flag.spent);
              final budgetFmt = currencyFormatter.format(flag.budget);
              final overFmt = currencyFormatter.format(flag.overrunAmount);

              return Container(
                key: Key('category_overrun_flag_${flag.categoryUuid}'),
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _warningBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _warningBg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        flag.categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$spentFmt / $budgetFmt (+$overFmt)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _warningText,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
