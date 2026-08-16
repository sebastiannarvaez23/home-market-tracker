import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/quantity.dart';

class Money extends Equatable implements Comparable<Money> {
  const Money.cents(this.cents) : assert(cents >= 0, 'Money cannot be negative');

  factory Money.zero() => const Money.cents(0);

  final int cents;

  double get amount => cents / 100.0;

  static Result<Money> parse(
    num value, {
    bool allowZero = false,
    String zeroMessage = 'El precio debe ser mayor a 0.',
  }) {
    if (value.isNaN || value.isInfinite) {
      return const Result.failure(Failure.validation('El monto no es válido.'));
    }
    final parsedCents = (value * 100).round();
    if (parsedCents < 0) {
      return const Result.failure(
        Failure.validation('El monto no puede ser negativo.'),
      );
    }
    if (!allowZero && parsedCents == 0) {
      return Result.failure(Failure.validation(zeroMessage));
    }
    return Result.success(Money.cents(parsedCents));
  }

  Money operator +(Money other) => Money.cents(cents + other.cents);

  Money minusClamped(Money other) {
    final result = cents - other.cents;
    return Money.cents(result < 0 ? 0 : result);
  }

  Money times(Quantity quantity) {
    final result = (cents * quantity.milliUnits / 1000).round();
    return Money.cents(result);
  }

  bool operator >(Money other) => cents > other.cents;

  bool operator <(Money other) => cents < other.cents;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  List<Object?> get props => [cents];
}
