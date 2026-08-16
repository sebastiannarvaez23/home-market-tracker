import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_line.dart';

class HistoryEntryModel {
  const HistoryEntryModel({
    required this.id,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.completedAt,
    required this.totalAmount,
    required this.itemCount,
  });

  final String id;
  final String marketId;
  final String marketNameSnapshot;
  final int completedAt;
  final double totalAmount;
  final int itemCount;

  factory HistoryEntryModel.fromMap(Map<String, Object?> map) {
    return HistoryEntryModel(
      id: map[ShoppingSessionColumns.id]! as String,
      marketId: map[ShoppingSessionColumns.marketId]! as String,
      marketNameSnapshot: map[ShoppingSessionColumns.marketNameSnapshot]! as String,
      completedAt: map[ShoppingSessionColumns.completedAt]! as int,
      totalAmount: (map[ShoppingSessionColumns.totalAmount] as num).toDouble(),
      itemCount: (map['item_count'] as num).toInt(),
    );
  }

  HistoryEntry toEntity() {
    return HistoryEntry(
      id: id,
      marketId: marketId,
      marketNameSnapshot: marketNameSnapshot,
      completedAt: completedAt,
      total: Money.cents((totalAmount * 100).round()),
      itemCount: itemCount,
    );
  }
}

class HistoryLineModel {
  const HistoryLineModel({
    required this.id,
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.uom,
    this.uomFactor = 1,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String id;
  final String productId;
  final String productNameSnapshot;
  final double quantity;
  final String uom;
  final double uomFactor;
  final double unitPrice;
  final double lineTotal;

  factory HistoryLineModel.fromMap(Map<String, Object?> map) {
    return HistoryLineModel(
      id: map[ShoppingItemColumns.id]! as String,
      productId: map[ShoppingItemColumns.productId]! as String,
      productNameSnapshot: map[ShoppingItemColumns.productNameSnapshot]! as String,
      quantity: (map[ShoppingItemColumns.quantity] as num).toDouble(),
      uom: map[ShoppingItemColumns.uom]! as String,
      uomFactor: (map[ShoppingItemColumns.uomFactor] as num?)?.toDouble() ?? 1,
      unitPrice: (map[ShoppingItemColumns.unitPrice] as num).toDouble(),
      lineTotal: (map[ShoppingItemColumns.lineTotal] as num).toDouble(),
    );
  }

  HistoryLine toEntity() {
    return HistoryLine(
      id: id,
      productId: productId,
      productNameSnapshot: productNameSnapshot,
      quantity: Quantity.milli((quantity * 1000).round()),
      uom: UnitOfMeasure.fromStorage(uom),
      uomFactor: Quantity.milli((uomFactor * 1000).round()),
      unitPrice: Money.cents((unitPrice * 100).round()),
      lineTotal: Money.cents((lineTotal * 100).round()),
    );
  }
}

class HistoryDetailModel {
  const HistoryDetailModel({
    required this.id,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.completedAt,
    required this.totalAmount,
    required this.lines,
  });

  final String id;
  final String marketId;
  final String marketNameSnapshot;
  final int completedAt;
  final double totalAmount;
  final List<HistoryLineModel> lines;

  HistoryDetail toEntity() {
    return HistoryDetail(
      id: id,
      marketId: marketId,
      marketNameSnapshot: marketNameSnapshot,
      completedAt: completedAt,
      total: Money.cents((totalAmount * 100).round()),
      lines: lines.map((line) => line.toEntity()).toList(growable: false),
    );
  }
}
