import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';

enum UnitDimension { count, mass, volume }

enum UnitOfMeasure {
  unit('Und', 'Unidad', UnitDimension.count, 1),
  pound('Lb', 'Libra', UnitDimension.mass, 453592),
  liter('Lt', 'Litro', UnitDimension.volume, 1000000),
  milliliter('Ml', 'Mililitro', UnitDimension.volume, 1000),
  gram('Gr', 'Gramo', UnitDimension.mass, 1000),
  kilogram('Kg', 'Kilogramo', UnitDimension.mass, 1000000),
  pack('Pq', 'Paquete', UnitDimension.count, 1);

  const UnitOfMeasure(this.code, this.label, this.dimension, this.baseFactor);

  /// Código persistido. Catálogo cerrado: Und, Lb, Lt, Ml, Gr, Kg, Pq.
  final String code;

  /// Nombre de negocio para listados y pickers.
  final String label;

  final UnitDimension dimension;

  /// Factor hacia la unidad base de la dimensión: mg (masa), µL (volumen), 1 (conteo).
  final int baseFactor;

  static const catalog = values;

  static Result<UnitOfMeasure> parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const Result.failure(
        Failure.validation('La unidad de medida es obligatoria.'),
      );
    }
    final normalized = raw.trim().toLowerCase();
    for (final unit in catalog) {
      if (unit.code.toLowerCase() == normalized) {
        return Result.success(unit);
      }
    }
    return const Result.failure(
      Failure.validation('La unidad de medida no es válida.'),
    );
  }

  static UnitOfMeasure fromStorage(String code) {
    final result = parse(code);
    return switch (result) {
      Success<UnitOfMeasure>(:final value) => value,
      FailureResult<UnitOfMeasure>(:final failure) =>
        throw ArgumentError(failure.message),
    };
  }

  bool canConvertTo(UnitOfMeasure target) {
    if (this == target) return true;
    if (dimension != target.dimension) return false;
    return dimension != UnitDimension.count;
  }

  Result<Quantity> convertQuantity(Quantity quantity, UnitOfMeasure target) {
    if (!canConvertTo(target)) {
      return const Result.failure(
        Failure.validation('No se pueden convertir esas unidades de medida.'),
      );
    }
    if (this == target) return Result.success(quantity);
    final milli =
        (quantity.milliUnits * baseFactor / target.baseFactor).round();
    if (milli <= 0) {
      return const Result.failure(
        Failure.validation('La cantidad convertida no es válida.'),
      );
    }
    return Result.success(Quantity.milli(milli));
  }

  Result<Money> convertUnitPrice(Money unitPrice, UnitOfMeasure target) {
    if (!canConvertTo(target)) {
      return const Result.failure(
        Failure.validation('No se pueden convertir esas unidades de medida.'),
      );
    }
    if (this == target) return Result.success(unitPrice);
    final cents =
        (unitPrice.cents * target.baseFactor / baseFactor).round();
    if (cents < 0) {
      return const Result.failure(
        Failure.validation('El precio convertido no es válido.'),
      );
    }
    return Result.success(Money.cents(cents));
  }

  /// Precio por unidad base, a escala entera, para comparar UoM convertibles.
  int comparableUnitPrice(Money unitPrice) {
    return unitPrice.cents * _comparisonScale ~/ baseFactor;
  }

  static const _comparisonScale = 1000000;
}
