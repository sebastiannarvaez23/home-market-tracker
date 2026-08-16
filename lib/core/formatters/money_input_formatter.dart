import 'package:flutter/services.dart';

abstract final class MoneyInputFormatter {
  static final digitsOnly = RegExp(r'[^0-9]');

  static String formatPesos(int pesos) {
    if (pesos < 0) pesos = 0;
    return '\$ ${_group(pesos)}';
  }

  static int? parsePesos(String raw) {
    final digits = raw.replaceAll(digitsOnly, '');
    if (digits.isEmpty) return null;
    return int.parse(digits);
  }

  static String _group(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(remaining <= 4 ? '.' : "'");
      }
    }
    return buffer.toString();
  }
}

class MoneyInputTextFormatter extends TextInputFormatter {
  const MoneyInputTextFormatter({this.maxDigits = 9});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(MoneyInputFormatter.digitsOnly, '');
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final formatted = MoneyInputFormatter.formatPesos(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
