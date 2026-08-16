import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';

class Quantity extends Equatable {
  const Quantity.milli(this.milliUnits)
      : assert(milliUnits > 0, 'Quantity must be greater than 0');

  factory Quantity.one() => const Quantity.milli(1000);

  final int milliUnits;

  double get value => milliUnits / 1000.0;

  String get compact {
    if (milliUnits % 1000 == 0) return '${milliUnits ~/ 1000}';
    return value.toString();
  }

  static const int maxMilli = 9999 * 1000;

  static Result<Quantity> parse(num value) {
    if (value.isNaN || value.isInfinite) {
      return const Result.failure(
        Failure.validation('La cantidad no es válida.'),
      );
    }
    final milli = (value * 1000).round();
    if (milli <= 0) {
      return const Result.failure(
        Failure.validation('La cantidad debe ser mayor a 0.'),
      );
    }
    if (milli > maxMilli) {
      return const Result.failure(
        Failure.validation('La cantidad no puede superar 9999.'),
      );
    }
    return Result.success(Quantity.milli(milli));
  }

  Quantity timesQuantity(Quantity other) {
    final milli = (milliUnits * other.milliUnits / 1000).round();
    return Quantity.milli(milli < 1 ? 1 : milli);
  }

  @override
  List<Object?> get props => [milliUnits];
}
