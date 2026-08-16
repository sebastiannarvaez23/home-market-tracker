import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.uom,
    this.uomFactor = const Quantity.milli(1000),
    required this.unitPrice,
  });

  final String id;
  final String sessionId;
  final String productId;
  final String productNameSnapshot;
  final Quantity quantity;
  final UnitOfMeasure uom;
  final Quantity uomFactor;
  final Money unitPrice;

  Money get lineTotal => unitPrice.times(quantity);

  @override
  List<Object?> get props => [
        id,
        sessionId,
        productId,
        productNameSnapshot,
        quantity,
        uom,
        uomFactor,
        unitPrice,
      ];
}
