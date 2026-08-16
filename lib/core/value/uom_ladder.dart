import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

class UomStepDraft {
  const UomStepDraft({required this.uom, required this.factor});

  final UnitOfMeasure uom;
  final num factor;
}

class UomLadderDraft {
  const UomLadderDraft({
    this.base = UnitOfMeasure.unit,
    this.steps = const [],
  });

  final UnitOfMeasure base;
  final List<UomStepDraft> steps;
}

class UomLadderStep extends Equatable {
  const UomLadderStep({required this.uom, required this.factor});

  final UnitOfMeasure uom;
  final Quantity factor;

  String labelRelativeTo(UnitOfMeasure base) {
    return '${uom.code} = ${factor.compact} ${base.code}';
  }

  @override
  List<Object?> get props => [uom, factor];
}

class UomLadder extends Equatable {
  const UomLadder({
    required this.base,
    this.steps = const [],
  });

  static const unitOnly = UomLadder(base: UnitOfMeasure.unit);

  final UnitOfMeasure base;
  final List<UomLadderStep> steps;

  UomLadderStep get baseStep => UomLadderStep(
        uom: base,
        factor: Quantity.one(),
      );

  /// Unidad mínima y cada tamaño de empaque. El mismo código (p. ej. `Pq`)
  /// puede aparecer más de una vez si el factor a la mínima es distinto.
  List<UomLadderStep> get selectable => [baseStep, ...steps];

  bool allows(UnitOfMeasure uom) {
    return uom == base || steps.any((step) => step.uom == uom);
  }

  String labelOf(UomLadderStep step) {
    if (step.uom == base && step.factor == Quantity.one()) {
      return base.code;
    }
    return step.labelRelativeTo(base);
  }

  Result<UomLadderStep> resolve({
    UnitOfMeasure? uom,
    Quantity? factor,
  }) {
    if (uom == null || uom == base) {
      if (factor == null || factor == Quantity.one()) {
        return Result.success(baseStep);
      }
      return const Result.failure(
        Failure.validation(
          'La unidad mínima no admite un factor distinto de 1.',
        ),
      );
    }
    final matches = [
      for (final step in steps)
        if (step.uom == uom && (factor == null || step.factor == factor)) step,
    ];
    if (matches.length == 1) {
      return Result.success(matches.single);
    }
    if (matches.isEmpty) {
      return const Result.failure(
        Failure.validation(
          'La unidad no está configurada para este producto.',
        ),
      );
    }
    return const Result.failure(
      Failure.validation(
        'Hay varios tamaños de esa unidad; indica cuántas unidades mínimas contiene.',
      ),
    );
  }

  Result<Quantity> factorToBase(UnitOfMeasure uom, {Quantity? packagingFactor}) {
    final resolved = resolve(uom: uom, factor: packagingFactor);
    if (resolved is FailureResult<UomLadderStep>) {
      return Result.failure(resolved.failure);
    }
    return Result.success((resolved as Success<UomLadderStep>).value.factor);
  }

  Result<Quantity> toBase(
    Quantity quantity,
    UnitOfMeasure from, {
    Quantity? packagingFactor,
  }) {
    final factorResult = factorToBase(from, packagingFactor: packagingFactor);
    if (factorResult is FailureResult<Quantity>) {
      return factorResult;
    }
    final factor = (factorResult as Success<Quantity>).value;
    return Result.success(quantity.timesQuantity(factor));
  }

  Result<Money> unitPriceToBase(
    Money unitPrice,
    UnitOfMeasure from, {
    Quantity? packagingFactor,
  }) {
    final factorResult = factorToBase(from, packagingFactor: packagingFactor);
    if (factorResult is FailureResult<Quantity>) {
      return Result.failure(factorResult.failure);
    }
    final factor = (factorResult as Success<Quantity>).value;
    final cents = (unitPrice.cents * 1000 / factor.milliUnits).round();
    if (cents < 0) {
      return const Result.failure(
        Failure.validation('El precio convertido no es válido.'),
      );
    }
    return Result.success(Money.cents(cents));
  }

  static Result<UomLadder> parse(UomLadderDraft draft) {
    final parsedSteps = <UomLadderStep>[];
    final usedPackagings = <UomLadderStep>{};
    for (final step in draft.steps) {
      if (step.uom == draft.base) {
        return const Result.failure(
          Failure.validation(
            'Un peldaño no puede repetir la unidad mínima.',
          ),
        );
      }
      final factorResult = Quantity.parse(step.factor);
      if (factorResult is FailureResult<Quantity>) {
        return Result.failure(factorResult.failure);
      }
      final parsed = UomLadderStep(
        uom: step.uom,
        factor: (factorResult as Success<Quantity>).value,
      );
      if (usedPackagings.contains(parsed)) {
        return const Result.failure(
          Failure.validation(
            'Ese tamaño de empaque ya está en la escalera del producto.',
          ),
        );
      }
      usedPackagings.add(parsed);
      parsedSteps.add(parsed);
    }
    return Result.success(
      UomLadder(base: draft.base, steps: parsedSteps),
    );
  }

  @override
  List<Object?> get props => [base, steps];
}
