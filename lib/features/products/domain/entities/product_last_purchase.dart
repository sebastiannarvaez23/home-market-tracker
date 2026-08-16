import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

class ProductLastPurchase extends Equatable {
  const ProductLastPurchase({
    required this.marketName,
    required this.unitPrice,
    required this.uom,
    this.uomFactor = const Quantity.milli(1000),
    required this.purchasedAt,
  });

  final String marketName;
  final Money unitPrice;
  final UnitOfMeasure uom;
  final Quantity uomFactor;
  final int purchasedAt;

  @override
  List<Object?> get props => [marketName, unitPrice, uom, uomFactor, purchasedAt];
}
