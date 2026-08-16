import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

class HistoryLine extends Equatable {
  const HistoryLine({
    required this.id,
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.uom,
    this.uomFactor = const Quantity.milli(1000),
    required this.unitPrice,
    required this.lineTotal,
  });

  final String id;
  final String productId;
  final String productNameSnapshot;
  final Quantity quantity;
  final UnitOfMeasure uom;
  final Quantity uomFactor;
  final Money unitPrice;
  final Money lineTotal;

  @override
  List<Object?> get props => [
        id,
        productId,
        productNameSnapshot,
        quantity,
        uom,
        uomFactor,
        unitPrice,
        lineTotal,
      ];
}
