import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

void main() {
  test('el catálogo cerrado usa los códigos definidos', () {
    expect(
      UnitOfMeasure.catalog.map((unit) => unit.code).toList(),
      ['Und', 'Lb', 'Lt', 'Ml', 'Gr', 'Kg', 'Pq'],
    );
  });

  test('parsea códigos sin importar mayúsculas', () {
    expect(UnitOfMeasure.parse('kg').valueOrNull, UnitOfMeasure.kilogram);
    expect(UnitOfMeasure.parse('UND').valueOrNull, UnitOfMeasure.unit);
  });

  test('rechaza unidad vacía o desconocida', () {
    expect(UnitOfMeasure.parse(null).failureOrNull?.code, FailureCode.validation);
    expect(UnitOfMeasure.parse('  ').failureOrNull?.code, FailureCode.validation);
    expect(UnitOfMeasure.parse('Oz').failureOrNull?.code, FailureCode.validation);
  });

  test('convierte masa Kg ↔ Gr y el precio unitario', () {
    const twoKg = Quantity.milli(2000);
    final grams = UnitOfMeasure.kilogram.convertQuantity(
      twoKg,
      UnitOfMeasure.gram,
    );
    expect((grams as Success<Quantity>).value, const Quantity.milli(2000000));

    final pricePerGram = UnitOfMeasure.kilogram.convertUnitPrice(
      const Money.cents(1000000),
      UnitOfMeasure.gram,
    );
    expect((pricePerGram as Success<Money>).value, const Money.cents(1000));
  });

  test('convierte volumen Lt ↔ Ml', () {
    final milliliters = UnitOfMeasure.liter.convertQuantity(
      Quantity.one(),
      UnitOfMeasure.milliliter,
    );
    expect(
      (milliliters as Success<Quantity>).value,
      const Quantity.milli(1000000),
    );
  });

  test('no convierte dimensiones distintas ni Und ↔ Pq', () {
    expect(
      UnitOfMeasure.kilogram.canConvertTo(UnitOfMeasure.liter),
      isFalse,
    );
    expect(
      UnitOfMeasure.unit.canConvertTo(UnitOfMeasure.pack),
      isFalse,
    );
    expect(
      UnitOfMeasure.kilogram
          .convertQuantity(Quantity.one(), UnitOfMeasure.liter)
          .isFailure,
      isTrue,
    );
  });

  test('compara precios por unidad base entre UoM convertibles', () {
    final perKg = UnitOfMeasure.kilogram.comparableUnitPrice(
      const Money.cents(500000),
    );
    final perGram = UnitOfMeasure.gram.comparableUnitPrice(
      const Money.cents(600),
    );
    expect(perGram > perKg, isTrue);
  });
}
