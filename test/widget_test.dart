import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/formatters/money_formatter.dart';
import 'package:home_market_tracker/core/value/money.dart';

void main() {
  test('MoneyFormatter usa formato es-CO', () {
    expect(MoneyFormatter.format(const Money.cents(1234)), r'$12,34');
  });
}
