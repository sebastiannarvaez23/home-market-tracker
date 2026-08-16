import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';

void main() {
  test('Pq → 2 Und convierte a la unidad mínima', () {
    final ladder = UomLadder.parse(
      const UomLadderDraft(
        base: UnitOfMeasure.unit,
        steps: [
          UomStepDraft(uom: UnitOfMeasure.pack, factor: 2),
        ],
      ),
    );
    final value = (ladder as Success<UomLadder>).value;
    expect(value.allows(UnitOfMeasure.pack), isTrue);
    expect(
      value.toBase(Quantity.one(), UnitOfMeasure.pack).valueOrNull,
      const Quantity.milli(2000),
    );
    expect(
      value.unitPriceToBase(const Money.cents(1000), UnitOfMeasure.pack).valueOrNull,
      const Money.cents(500),
    );
  });

  test('Pq → 3 Lb usa la mínima configurada', () {
    final ladder = UomLadder.parse(
      const UomLadderDraft(
        base: UnitOfMeasure.pound,
        steps: [
          UomStepDraft(uom: UnitOfMeasure.pack, factor: 3),
        ],
      ),
    );
    final value = (ladder as Success<UomLadder>).value;
    expect(value.base, UnitOfMeasure.pound);
    expect(
      value.toBase(Quantity.one(), UnitOfMeasure.pack).valueOrNull,
      const Quantity.milli(3000),
    );
  });

  test('permite el mismo UoM con distintos tamaños: Pq 3 Und y Pq 4 Und', () {
    final ladder = UomLadder.parse(
      const UomLadderDraft(
        steps: [
          UomStepDraft(uom: UnitOfMeasure.pack, factor: 3),
          UomStepDraft(uom: UnitOfMeasure.pack, factor: 4),
        ],
      ),
    );
    final value = (ladder as Success<UomLadder>).value;
    expect(value.steps, hasLength(2));
    expect(
      value
          .toBase(
            Quantity.one(),
            UnitOfMeasure.pack,
            packagingFactor: const Quantity.milli(3000),
          )
          .valueOrNull,
      const Quantity.milli(3000),
    );
    expect(
      value
          .toBase(
            Quantity.one(),
            UnitOfMeasure.pack,
            packagingFactor: const Quantity.milli(4000),
          )
          .valueOrNull,
      const Quantity.milli(4000),
    );
    expect(
      value.resolve(uom: UnitOfMeasure.pack).failureOrNull?.code,
      FailureCode.validation,
    );
    expect(
      value
          .resolve(
            uom: UnitOfMeasure.pack,
            factor: const Quantity.milli(3000),
          )
          .valueOrNull
          ?.labelRelativeTo(UnitOfMeasure.unit),
      'Pq = 3 Und',
    );
  });

  test('rechaza repetir la unidad mínima como peldaño', () {
    final result = UomLadder.parse(
      const UomLadderDraft(
        steps: [
          UomStepDraft(uom: UnitOfMeasure.unit, factor: 2),
        ],
      ),
    );
    expect(result.failureOrNull?.code, FailureCode.validation);
  });

  test('rechaza el mismo empaque duplicado (mismo UoM y factor)', () {
    final result = UomLadder.parse(
      const UomLadderDraft(
        steps: [
          UomStepDraft(uom: UnitOfMeasure.pack, factor: 3),
          UomStepDraft(uom: UnitOfMeasure.pack, factor: 3),
        ],
      ),
    );
    expect(result.failureOrNull?.code, FailureCode.validation);
  });
}
