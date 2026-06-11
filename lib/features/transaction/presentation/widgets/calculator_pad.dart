import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorPad extends StatelessWidget {
  const CalculatorPad({
    required this.onKeyPress,
    required this.onSubmit,
    super.key,
  });

  final void Function(String) onKeyPress;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['C', '÷', 'x', 'BACKSPACE']),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9', '-']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6', '+']),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(child: _buildRow(['1', '2', '3'])),
                    const SizedBox(height: 8),
                    Expanded(child: _buildRow(['.', '0', '00'])),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _SubmitButton(onPressed: onSubmit),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _CalcButton(
              label: key,
              onPressed: () => onKeyPress(key),
              isOperator: ['+', '-', 'x', '÷'].contains(key),
              isAction: ['C', 'BACKSPACE'].contains(key),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    required this.label,
    required this.onPressed,
    this.isOperator = false,
    this.isAction = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isOperator;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    final bgColor = isOperator || isAction
        ? const Color(0xFFEDEEEF)
        : const Color(0xFFFFFFFF);
    final textColor = isOperator
        ? const Color(0xFF00113A)
        : const Color(0xFF191C1D);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 64, // fixed height for rows
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: label == 'BACKSPACE'
              ? Icon(Icons.backspace_outlined, color: textColor, size: 20)
              : Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: isOperator || isAction
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          colors: [Color(0xFF00113A), Color(0xFF002366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00113A).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(100),
          child: const Center(
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
