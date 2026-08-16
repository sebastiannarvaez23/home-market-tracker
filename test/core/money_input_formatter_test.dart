import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/formatters/money_input_formatter.dart';

void main() {
  test('agrupa miles con punto y millones con apostrofe', () {
    expect(MoneyInputFormatter.formatPesos(500), r'$ 500');
    expect(MoneyInputFormatter.formatPesos(3200), r'$ 3.200');
    expect(MoneyInputFormatter.formatPesos(1500000), "\$ 1'500.000");
    expect(MoneyInputFormatter.formatPesos(1234567890), "\$ 1'234'567.890");
  });

  test('parsea solo los dígitos de la máscara', () {
    expect(MoneyInputFormatter.parsePesos("\$ 1'500.000"), 1500000);
    expect(MoneyInputFormatter.parsePesos(r'$ 3.200'), 3200);
    expect(MoneyInputFormatter.parsePesos('abc'), isNull);
    expect(MoneyInputFormatter.parsePesos(''), isNull);
  });

  test('el input formatter deja únicamente números enmascarados', () {
    const formatter = MoneyInputTextFormatter();
    final next = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: r'a1b500c000'),
    );
    expect(next.text, "\$ 1'500.000");
  });
}
