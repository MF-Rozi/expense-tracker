import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionHistoryFilterSheet extends StatefulWidget {
  const TransactionHistoryFilterSheet({
    required this.onApply,
    super.key,
    this.initialCategoryId,
    this.initialStartDate,
    this.initialEndDate,
  });

  final String? initialCategoryId;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final void Function(DateTime? start, DateTime? end, String? categoryId)
      onApply;

  @override
  State<TransactionHistoryFilterSheet> createState() =>
      _TransactionHistoryFilterSheetState();
}

class _TransactionHistoryFilterSheetState
    extends State<TransactionHistoryFilterSheet> {
  String? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectDateRange() async {
    final initialRange = _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null;

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00113A),
              surface: Color(0xFFF8F9FA),
              onSurface: Color(0xFF00113A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF00113A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Ledger',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00113A),
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategoryId = null;
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: Text(
                    'Reset All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFBA1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'DATE RANGE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF757682),
              ),
            ),
            const SizedBox(height: 8),
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            Text(
              'CATEGORY',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF757682),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  final categories = state.allCategories;
                  if (state.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (categories.isEmpty) {
                    return Text(
                      'No categories available',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF444650),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected =
                            _selectedCategoryId == category.uuid.getOrCrash();
                        return _buildCategoryChip(category, isSelected);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_startDate, _endDate, _selectedCategoryId);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00113A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final hasDates = _startDate != null && _endDate != null;
    final dateText = hasDates
        ? '${DateFormat('MMM d, yyyy').format(_startDate!)} - '
            '${DateFormat('MMM d, yyyy').format(_endDate!)}'
        : 'Select custom date range';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF444650),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _selectDateRange,
              behavior: HitTestBehavior.opaque,
              child: Text(
                dateText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hasDates
                      ? const Color(0xFF00113A)
                      : const Color(0xFF757682),
                ),
              ),
            ),
          ),
          if (hasDates)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF444650)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Category category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = isSelected ? null : category.uuid.getOrCrash();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00113A) : const Color(0xFFF3F4F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00113A) : Colors.transparent,
          ),
        ),
        child: Text(
          category.name.getOrCrash(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF444650),
          ),
        ),
      ),
    );
  }
}
