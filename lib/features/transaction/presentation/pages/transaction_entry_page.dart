import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/widgets/category_list_item.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
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
  final FocusNode _noteFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
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
    _noteFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BuildContext context) {
    final transactionCubit = context.read<TransactionCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: getIt<CategoryCubit>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF00113A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Select Ledger Category',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00113A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Assign this transaction to an envelope.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF444650),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categories = state.allCategories;
                    if (categories.isEmpty) {
                      return Center(
                        child: Text(
                          'No categories found.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF444650),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final String subtitle;
                        if (category.parentUuid != null) {
                          final parent = categories.firstWhere(
                            (c) =>
                                c.uuid.getOrCrash() ==
                                category.parentUuid!.getOrCrash(),
                            orElse: () => category,
                          );
                          subtitle = parent.name.getOrCrash();
                        } else {
                          subtitle = 'Root Category';
                        }

                        return CategoryListItem(
                          category: category,
                          subtitle: subtitle,
                          onTap: () {
                            transactionCubit.selectCategory(category);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      // Master Display Card
                      _MasterDisplayCard(
                        amount: state.parsedAmount,
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                      ),
                      const SizedBox(height: 32),

                      // Description
                      _BentoInputCell(
                        label: 'Description',
                        child: TextFormField(
                          controller: _descriptionController,
                          focusNode: _noteFocusNode,
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

                      // Category
                      _BentoInputCell(
                        label: 'Category',
                        child: InkWell(
                          onTap: () => _showCategoryPicker(context),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  state.selectedCategory?.name.getOrCrash() ??
                                      'Select Category',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: state.selectedCategory != null
                                        ? const Color(0xFF191C1D)
                                        : const Color(0xFF444650),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF444650),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date
                      _BentoInputCell(
                        label: 'Date',
                        child: InkWell(
                          onTap: () async {
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
                    ],
                  ),
                ),
              ),

              // Calculator Pad (hide if system keyboard is up)
              if (!_noteFocusNode.hasFocus)
                Container(
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
                      onSubmit: () =>
                          context.read<TransactionCubit>().submitTransaction(),
                    ),
                  ),
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
  });

  final double amount;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0, // Since it's IDR, usually no decimals for display
    ).format(amount);

    return GestureDetector(
      onTap: focusNode.requestFocus,
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
            FittedBox(
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
