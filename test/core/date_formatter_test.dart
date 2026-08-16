import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/formatters/date_formatter.dart';

void main() {
  test('DateFormatter.dayMonthYear usa dd/MM/yyyy', () {
    final epoch = DateTime(2026, 8, 15).millisecondsSinceEpoch;
    expect(DateFormatter.dayMonthYear(epoch), '15/08/2026');
  });

  test('DateFormatter.monthYear usa mes corto y año', () {
    expect(DateFormatter.monthYear(DateTime(2026, 8, 15)), 'Ago 2026');
    expect(DateFormatter.monthShort(DateTime(2026, 3, 1)), 'Mar');
  });
}
