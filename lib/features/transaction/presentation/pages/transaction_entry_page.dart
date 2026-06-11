import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:template/features/transaction/presentation/blocs/transaction_cubit.dart';
import 'package:template/features/transaction/presentation/blocs/transaction_state.dart';
import 'package:template/features/transaction/presentation/widgets/calculator_pad.dart';

class TransactionEntryPage extends StatefulWidget {
  const TransactionEntryPage({super.key});

  @override
  State<TransactionEntryPage> createState() => _TransactionEntryPageState();
}

class _TransactionEntryPageState extends State<TransactionEntryPage> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF00113A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Transaction',
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
        },
        builder: (context, state) {
          final isKeyboardVisible =
              MediaQuery.of(context).viewInsets.bottom > 0;

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
                        expression: state.rawExpression,
                      ),
                      const SizedBox(height: 32),

                      // Description
                      _BentoInputCell(
                        label: 'Description',
                        child: TextFormField(
                          controller: _descriptionController,
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
                          onTap: () {
                            // TODO(mfrozi): Show category picker bottom sheet.
                          },
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
              if (!isKeyboardVisible)
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
    required this.expression,
  });

  final double amount;
  final String expression;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'IDR ',
      decimalDigits: 0, // Since it's IDR, usually no decimals for display
    ).format(amount);

    return Container(
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
          Text(
            expression.isEmpty ? '0' : expression,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF444650),
              letterSpacing: 2,
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
