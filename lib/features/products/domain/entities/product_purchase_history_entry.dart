import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

class ProductPurchaseHistoryEntry extends Equatable {
  const ProductPurchaseHistoryEntry({
    required this.id,
    required this.marketName,
    required this.unitPrice,
    required this.quantity,
    required this.uom,
    this.uomFactor = const Quantity.milli(1000),
    required this.purchasedAt,
  });

  final String id;
  final String marketName;
  final Money unitPrice;
  final Quantity quantity;
  final UnitOfMeasure uom;
  final Quantity uomFactor;
  final int purchasedAt;

  @override
  List<Object?> get props =>
      [id, marketName, unitPrice, quantity, uom, uomFactor, purchasedAt];
}
