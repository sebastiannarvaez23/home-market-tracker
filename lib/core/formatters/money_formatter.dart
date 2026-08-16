import 'package:home_market_tracker/core/value/money.dart';

abstract final class MoneyFormatter {
  static String format(Money money) {
    final negative = money.cents < 0;
    final cents = money.cents.abs();
    final whole = cents ~/ 100;
    final fraction = cents % 100;
    final grouped = _thousands(whole);
    final sign = negative ? '-' : '';
    if (fraction == 0) {
      return '$sign\$$grouped';
    }
    final decimals = fraction.toString().padLeft(2, '0');
    return '$sign\$$grouped,$decimals';
  }

  static String _thousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}
