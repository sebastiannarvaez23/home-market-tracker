import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';

class ProductPurchaseHistoryModel {
  const ProductPurchaseHistoryModel({
    required this.id,
    required this.marketName,
    required this.unitPrice,
    required this.quantity,
    required this.uom,
    this.uomFactor = 1,
    required this.purchasedAt,
  });

  final String id;
  final String marketName;
  final double unitPrice;
  final double quantity;
  final String uom;
  final double uomFactor;
  final int purchasedAt;

  factory ProductPurchaseHistoryModel.fromMap(Map<String, Object?> map) {
    return ProductPurchaseHistoryModel(
      id: map[ShoppingItemColumns.id]! as String,
      marketName: map[ShoppingSessionColumns.marketNameSnapshot]! as String,
      unitPrice: (map[ShoppingItemColumns.unitPrice] as num).toDouble(),
      quantity: (map[ShoppingItemColumns.quantity] as num).toDouble(),
      uom: map[ShoppingItemColumns.uom]! as String,
      uomFactor: (map[ShoppingItemColumns.uomFactor] as num?)?.toDouble() ?? 1,
      purchasedAt: map[ShoppingSessionColumns.completedAt]! as int,
    );
  }

  ProductPurchaseHistoryEntry toEntity() {
    return ProductPurchaseHistoryEntry(
      id: id,
      marketName: marketName,
      unitPrice: Money.cents((unitPrice * 100).round()),
      quantity: Quantity.milli((quantity * 1000).round()),
      uom: UnitOfMeasure.fromStorage(uom),
      uomFactor: Quantity.milli((uomFactor * 1000).round()),
      purchasedAt: purchasedAt,
    );
  }
}
