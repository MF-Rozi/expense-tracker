class ExpressionEvaluator {
  const ExpressionEvaluator();

  double evaluate(String expression) {
    if (expression.isEmpty || expression == '0') return 0.0;

    // 1. Sanitize
    String sanitized = expression
        .replaceAll('x', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    // Remove trailing operator for evaluation
    while (sanitized.isNotEmpty &&
        ['+', '-', '*', '/'].contains(sanitized[sanitized.length - 1])) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }

    if (sanitized.isEmpty) return 0.0;

    try {
      return _Parser(sanitized).parse();
    } catch (e) {
      return 0.0;
    }
  }
}

class _Parser {
  _Parser(this.input);
  final String input;
  int pos = -1;
  int ch = -1;

  void nextChar() {
    ch = (++pos < input.length) ? input.codeUnitAt(pos) : -1;
  }

  bool eat(int charToEat) {
    while (ch == 32) {
      nextChar();
    }
    if (ch == charToEat) {
      nextChar();
      return true;
    }
    return false;
  }

  double parse() {
    nextChar();
    final x = parseExpression();
    if (pos < input.length) throw Exception('Unexpected: ${String.fromCharCode(ch)}');
    return x;
  }

  double parseExpression() {
    var x = parseTerm();
    for (;;) {
      if (eat(43)) {
        x += parseTerm(); // +
      } else if (eat(45)) {
        x -= parseTerm(); // -
      } else {
        return x;
      }
    }
  }

  double parseTerm() {
    var x = parseFactor();
    for (;;) {
      if (eat(42)) {
        x *= parseFactor(); // *
      } else if (eat(47)) {
        x /= parseFactor(); // /
      } else {
        return x;
      }
    }
  }

  double parseFactor() {
    if (eat(43)) return parseFactor(); // unary +
    if (eat(45)) return -parseFactor(); // unary -

    double x;
    final startPos = pos;
    if (eat(40)) { // (
      x = parseExpression();
      eat(41); // )
    } else if ((ch >= 48 && ch <= 57) || ch == 46) { // numbers
      while ((ch >= 48 && ch <= 57) || ch == 46) {
        nextChar();
      }
      x = double.parse(input.substring(startPos, pos));
    } else {
      throw Exception('Unexpected: ${String.fromCharCode(ch)}');
    }

    return x;
  }
}
