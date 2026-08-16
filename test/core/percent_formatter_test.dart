import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/formatters/percent_formatter.dart';

void main() {
  test('formatea variación con signo', () {
    expect(PercentFormatter.signed(50), '+50%');
    expect(PercentFormatter.signed(-12.4), '-12%');
    expect(PercentFormatter.signed(0), '0%');
  });

  test('formatea el índice como entero', () {
    expect(PercentFormatter.whole(86.4), '86');
  });
}
