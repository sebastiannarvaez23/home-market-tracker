import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session_status.dart';

class ShoppingItemModel {
  const ShoppingItemModel({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.uom,
    this.uomFactor = 1,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String id;
  final String sessionId;
  final String productId;
  final String productNameSnapshot;
  final double quantity;
  final String uom;
  final double uomFactor;
  final double unitPrice;
  final double lineTotal;

  factory ShoppingItemModel.fromMap(Map<String, Object?> map) {
    return ShoppingItemModel(
      id: map[ShoppingItemColumns.id]! as String,
      sessionId: map[ShoppingItemColumns.sessionId]! as String,
      productId: map[ShoppingItemColumns.productId]! as String,
      productNameSnapshot: map[ShoppingItemColumns.productNameSnapshot]! as String,
      quantity: (map[ShoppingItemColumns.quantity] as num).toDouble(),
      uom: map[ShoppingItemColumns.uom]! as String,
      uomFactor: (map[ShoppingItemColumns.uomFactor] as num?)?.toDouble() ?? 1,
      unitPrice: (map[ShoppingItemColumns.unitPrice] as num).toDouble(),
      lineTotal: (map[ShoppingItemColumns.lineTotal] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      ShoppingItemColumns.id: id,
      ShoppingItemColumns.sessionId: sessionId,
      ShoppingItemColumns.productId: productId,
      ShoppingItemColumns.productNameSnapshot: productNameSnapshot,
      ShoppingItemColumns.quantity: quantity,
      ShoppingItemColumns.uom: uom,
      ShoppingItemColumns.uomFactor: uomFactor,
      ShoppingItemColumns.unitPrice: unitPrice,
      ShoppingItemColumns.lineTotal: lineTotal,
    };
  }

  factory ShoppingItemModel.fromEntity(ShoppingItem item) {
    return ShoppingItemModel(
      id: item.id,
      sessionId: item.sessionId,
      productId: item.productId,
      productNameSnapshot: item.productNameSnapshot,
      quantity: item.quantity.value,
      uom: item.uom.code,
      uomFactor: item.uomFactor.value,
      unitPrice: item.unitPrice.amount,
      lineTotal: item.lineTotal.amount,
    );
  }

  ShoppingItem toEntity() {
    return ShoppingItem(
      id: id,
      sessionId: sessionId,
      productId: productId,
      productNameSnapshot: productNameSnapshot,
      quantity: Quantity.milli((quantity * 1000).round()),
      uom: UnitOfMeasure.fromStorage(uom),
      uomFactor: Quantity.milli((uomFactor * 1000).round()),
      unitPrice: Money.cents((unitPrice * 100).round()),
    );
  }
}

class ShoppingSessionModel {
  const ShoppingSessionModel({
    required this.id,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.totalAmount,
    required this.items,
  });

  final String id;
  final String marketId;
  final String marketNameSnapshot;
  final String status;
  final int startedAt;
  final int? completedAt;
  final double totalAmount;
  final List<ShoppingItemModel> items;

  factory ShoppingSessionModel.fromMap(
    Map<String, Object?> map, {
    List<ShoppingItemModel> items = const [],
  }) {
    return ShoppingSessionModel(
      id: map[ShoppingSessionColumns.id]! as String,
      marketId: map[ShoppingSessionColumns.marketId]! as String,
      marketNameSnapshot: map[ShoppingSessionColumns.marketNameSnapshot]! as String,
      status: map[ShoppingSessionColumns.status]! as String,
      startedAt: map[ShoppingSessionColumns.startedAt]! as int,
      completedAt: map[ShoppingSessionColumns.completedAt] as int?,
      totalAmount: (map[ShoppingSessionColumns.totalAmount] as num).toDouble(),
      items: items,
    );
  }

  Map<String, Object?> toMap() {
    return {
      ShoppingSessionColumns.id: id,
      ShoppingSessionColumns.marketId: marketId,
      ShoppingSessionColumns.marketNameSnapshot: marketNameSnapshot,
      ShoppingSessionColumns.status: status,
      ShoppingSessionColumns.startedAt: startedAt,
      ShoppingSessionColumns.completedAt: completedAt,
      ShoppingSessionColumns.totalAmount: totalAmount,
    };
  }

  factory ShoppingSessionModel.fromEntity(ShoppingSession session) {
    return ShoppingSessionModel(
      id: session.id,
      marketId: session.marketId,
      marketNameSnapshot: session.marketNameSnapshot,
      status: session.status.storageValue,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      totalAmount: session.total.amount,
      items: session.items.map(ShoppingItemModel.fromEntity).toList(),
    );
  }

  ShoppingSession toEntity() {
    return ShoppingSession(
      id: id,
      marketId: marketId,
      marketNameSnapshot: marketNameSnapshot,
      status: ShoppingSessionStatus.fromStorage(status),
      startedAt: startedAt,
      completedAt: completedAt,
      items: items.map((item) => item.toEntity()).toList(growable: false),
    );
  }
}
