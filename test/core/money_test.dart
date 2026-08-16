import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';

void main() {
  group('Money', () {
    test('parsea a centavos con 2 decimales', () {
      final result = Money.parse(12.34);
      expect(result, isA<Success<Money>>());
      expect((result as Success<Money>).value.cents, 1234);
    });

    test('rechaza precio cero', () {
      final result = Money.parse(0);
      expect(result.failureOrNull?.code, FailureCode.validation);
    });

    test('multiplica por cantidad y redondea el subtotal', () {
      const price = Money.cents(199);
      const quantity = Quantity.milli(2500);
      expect(price.times(quantity).cents, 498);
    });
  });

  group('Quantity', () {
    test('rechaza cero y valores sobre 9999', () {
      expect(Quantity.parse(0).isFailure, isTrue);
      expect(Quantity.parse(10000).isFailure, isTrue);
    });
  });
}
