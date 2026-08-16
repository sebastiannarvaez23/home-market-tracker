import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/formatters/money_formatter.dart';
import 'package:home_market_tracker/core/value/money.dart';

void main() {
  test('formatea pesos enteros con separador de miles', () {
    expect(MoneyFormatter.format(const Money.cents(1850000)), r'$18.500');
  });

  test('formatea centavos con coma decimal', () {
    expect(MoneyFormatter.format(const Money.cents(1050)), r'$10,50');
  });
}
