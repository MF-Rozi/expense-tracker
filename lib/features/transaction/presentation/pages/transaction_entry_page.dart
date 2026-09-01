import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/widgets/hierarchical_envelope_picker_sheet.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_cubit.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_state.dart';
import 'package:expense_tracker/features/transaction/presentation/widgets/calculator_pad.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionEntryPage extends StatefulWidget {
  const TransactionEntryPage({super.key, this.existingTransaction});

  final Transaction? existingTransaction;

  @override
  State<TransactionEntryPage> createState() => _TransactionEntryPageState();
}

class _TransactionEntryPageState extends State<TransactionEntryPage> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  final FocusNode _noteFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  bool _isCalculatorVisible = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _noteController = TextEditingController(text: existing?.note ?? '');
    if (existing != null) {
      _descriptionController =
          TextEditingController(text: existing.description.getOrCrash());
      final amountVal = existing.amount.getOrCrash();
      _amountController = TextEditingController(
        text: amountVal == amountVal.toInt()
            ? amountVal.toInt().toString()
            : amountVal.toString(),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Category? category;
          try {
            category = getIt<CategoryCubit>().state.allCategories.firstWhere(
                  (c) => c.uuid == existing.categoryUuid,
                );
          } catch (_) {}
          context
              .read<TransactionCubit>()
              .loadExistingTransaction(existing, category);
        }
      });
    } else {
      _descriptionController = TextEditingController();
      _amountController = TextEditingController(text: '0');
    }
    _noteFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _noteFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BuildContext context, TransactionState state) {
    final transactionCubit = context.read<TransactionCubit>();
    final targetType = state.type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;

    HierarchicalEnvelopePickerSheet.show(
      context: context,
      targetType: targetType,
      categoryCubit: getIt<CategoryCubit>(),
      selectedCategory: state.selectedCategory,
    ).then((selected) {
      if (selected != null) {
        transactionCubit.selectCategory(selected);
      }
    });
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mortgage') ||
        lower.contains('rent') ||
        lower.contains('home') ||
        lower.contains('house')) {
      return Icons.home_outlined;
    } else if (lower.contains('util') || lower.contains('electric')) {
      return Icons.bolt_outlined;
    } else if (lower.contains('din') ||
        lower.contains('food') ||
        lower.contains('restaurant') ||
        lower.contains('coffee')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('travel') || lower.contains('flight')) {
      return Icons.flight_outlined;
    } else if (lower.contains('hobbi') || lower.contains('game')) {
      return Icons.sports_esports_outlined;
    } else if (lower.contains('market') ||
        lower.contains('invest') ||
        lower.contains('crypto')) {
      return Icons.bar_chart_outlined;
    } else if (lower.contains('salary') || lower.contains('paycheck')) {
      return Icons.account_balance_wallet_outlined;
    } else if (lower.contains('freelance') || lower.contains('client')) {
      return Icons.work_outline;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF00113A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.existingTransaction != null
              ? 'Edit Transaction'
              : 'New Transaction',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00113A),
          ),
        ),
      ),
      body: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionFormStatus.success) {
            Navigator.of(context).pop();
          } else if (state.status == TransactionFormStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
          if (_amountController.text != state.rawExpression) {
            _amountController.text = state.rawExpression;
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Transaction Type Toggle (Segmented Toggle)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<TransactionCubit>()
                                    .updateType(TransactionType.expense),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.type == TransactionType.expense
                                        ? const Color(0xFF00113A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Expense',
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.bold,
                                        color: state.type ==
                                                TransactionType.expense
                                            ? Colors.white
                                            : const Color(0xFF757682),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<TransactionCubit>()
                                    .updateType(TransactionType.income),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.type == TransactionType.income
                                        ? const Color(0xFF00113A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Income',
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            state.type == TransactionType.income
                                                ? Colors.white
                                                : const Color(0xFF757682),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Master Display Card
                      _MasterDisplayCard(
                        amount: state.parsedAmount,
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        isCalculatorVisible: _isCalculatorVisible,
                        onTap: () => setState(
                          () => _isCalculatorVisible = true,
                        ),
                        onHideCalculator: () =>
                            setState(() => _isCalculatorVisible = false),
                      ),
                      const SizedBox(height: 32),

                      // Description
                      _BentoInputCell(
                        label: 'Description',
                        child: TextFormField(
                          controller: _descriptionController,
                          focusNode: _noteFocusNode,
                          onTap: () =>
                              setState(() => _isCalculatorVisible = false),
                          onChanged: (val) => context
                              .read<TransactionCubit>()
                              .updateDescription(val),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF191C1D),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'What was this for?',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category / Envelope
                      _BentoInputCell(
                        label: 'Envelope',
                        child: BlocBuilder<CategoryCubit, CategoryState>(
                          bloc: getIt<CategoryCubit>(),
                          builder: (context, catState) {
                            final selectedCat = state.selectedCategory;
                            if (selectedCat == null) {
                              return InkWell(
                                onTap: () {
                                  setState(() => _isCalculatorVisible = false);
                                  _showCategoryPicker(context, state);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00113A)
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.folder_open_outlined,
                                        color: Color(0xFF757682),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Select Ledger Envelope',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF757682),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF757682),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final breadcrumb = selectedCat
                                .getBreadcrumbPath(catState.allCategories);
                            final hasBreadcrumb = breadcrumb.contains('›');

                            return InkWell(
                              onTap: () {
                                setState(() => _isCalculatorVisible = false);
                                _showCategoryPicker(context, state);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00113A)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconForCategory(
                                        selectedCat.name.getOrCrash(),
                                      ),
                                      color: const Color(0xFF00113A),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (hasBreadcrumb) ...[
                                          Text(
                                            breadcrumb,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF757682),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                        ],
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                selectedCat.name.getOrCrash(),
                                                style: GoogleFonts.manrope(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      const Color(0xFF191C1D),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEF0F2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                selectedCat
                                                    .behavioralModifier.name
                                                    .toUpperCase(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.6,
                                                  color:
                                                      const Color(0xFF757682),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF444650),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date
                      _BentoInputCell(
                        label: 'Date',
                        child: InkWell(
                          onTap: () async {
                            setState(() => _isCalculatorVisible = false);
                            final selected = await showDatePicker(
                              context: context,
                              initialDate: state.date ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (selected != null && context.mounted) {
                              context
                                  .read<TransactionCubit>()
                                  .updateDate(selected);
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(state.date ?? DateTime.now()),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF191C1D),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF444650),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Internal Note
                      _BentoInputCell(
                        label: 'Internal Note',
                        child: TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          onTap: () =>
                              setState(() => _isCalculatorVisible = false),
                          onChanged: (val) =>
                              context.read<TransactionCubit>().updateNote(val),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF191C1D),
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Add a private note about this transaction...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Save Transaction Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context
                              .read<TransactionCubit>()
                              .submitTransaction(),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: Text(
                            'Save Transaction',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00113A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Discard Draft Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Discard Draft',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF444650),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Calculator Pad (hide if system keyboard is up)
              if (!_noteFocusNode.hasFocus)
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.fastOutSlowIn,
                  child: _isCalculatorVisible
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: SizedBox(
                            height: 350,
                            child: CalculatorPad(
                              onKeyPress: (key) => context
                                  .read<TransactionCubit>()
                                  .updateExpression(key),
                              onSubmit: () => context
                                  .read<TransactionCubit>()
                                  .submitTransaction(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MasterDisplayCard extends StatelessWidget {
  const _MasterDisplayCard({
    required this.amount,
    required this.controller,
    required this.focusNode,
    required this.isCalculatorVisible,
    this.onTap,
    this.onHideCalculator,
  });

  final double amount;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onTap;
  final bool isCalculatorVisible;
  final VoidCallback? onHideCalculator;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0, // Since it's IDR, usually no decimals for display
    ).format(amount);

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00113A).withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              readOnly: true,
              showCursor: true,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF444650),
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isCalculatorVisible)
                  IconButton(
                    icon: const Icon(Icons.keyboard_hide),
                    onPressed: onHideCalculator,
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onTap,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedAmount,
                          style: GoogleFonts.manrope(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF00113A),
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoInputCell extends StatelessWidget {
  const _BentoInputCell({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFF00113A),
            ),
          ),
        ),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xFF00113A)
                        : const Color(0xFFE0E0E0),
                    width: isFocused ? 2 : 1,
                  ),
                ),
                child: child,
              );
            },
          ),
        ),
      ],
    );
  }
}
