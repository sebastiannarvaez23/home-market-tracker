import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';
import 'package:sqflite/sqflite.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardFacts> loadFacts(DashboardWindow window);
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  DashboardLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<DashboardFacts> loadFacts(DashboardWindow window) async {
    final db = await _database.connection;
    final sessionsInPeriod = await _sessionsBetween(
      db,
      window.periodStartMs,
      window.periodEndExclusiveMs,
    );
    final sessionsInPrevious = await _sessionsBetween(
      db,
      window.previousStartMs,
      window.previousEndExclusiveMs,
    );
    final trendSessions = await _sessionsBetween(
      db,
      window.trendStartMs,
      window.periodEndExclusiveMs,
    );
    final itemsInPeriod = await _itemsBetween(
      db,
      window.periodStartMs,
      window.periodEndExclusiveMs,
    );
    final minPrices = await _minUnitPrices(db, window.periodEndExclusiveMs);
    final itemCounts = await _itemCounts(db, window.periodEndExclusiveMs);

    return DashboardFacts(
      window: window,
      sessionsInPeriod: sessionsInPeriod,
      sessionsInPrevious: sessionsInPrevious,
      itemsInPeriod: itemsInPeriod,
      minUnitPriceByProductId: minPrices,
      completedItemCountByProductId: itemCounts,
      trendSessions: trendSessions,
    );
  }

  Future<List<SessionSpendFact>> _sessionsBetween(
    DatabaseExecutor db,
    int fromInclusive,
    int toExclusive,
  ) async {
    final rows = await db.rawQuery(
      '''
SELECT
  ${ShoppingSessionColumns.marketId},
  ${ShoppingSessionColumns.marketNameSnapshot},
  ${ShoppingSessionColumns.completedAt},
  ${ShoppingSessionColumns.totalAmount}
FROM ${DatabaseTables.shoppingSessions}
WHERE ${ShoppingSessionColumns.status} = ?
  AND ${ShoppingSessionColumns.completedAt} >= ?
  AND ${ShoppingSessionColumns.completedAt} < ?
''',
      [ShoppingSessionStatusValues.completed, fromInclusive, toExclusive],
    );
    return rows
        .map(
          (row) => SessionSpendFact(
            marketId: row[ShoppingSessionColumns.marketId]! as String,
            marketName: row[ShoppingSessionColumns.marketNameSnapshot]! as String,
            completedAt: row[ShoppingSessionColumns.completedAt]! as int,
            total: Money.cents(
              ((row[ShoppingSessionColumns.totalAmount] as num).toDouble() * 100)
                  .round(),
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<List<ItemSpendFact>> _itemsBetween(
    DatabaseExecutor db,
    int fromInclusive,
    int toExclusive,
  ) async {
    final rows = await db.rawQuery(
      '''
SELECT
  si.${ShoppingItemColumns.productId} AS product_id,
  si.${ShoppingItemColumns.productNameSnapshot} AS product_name,
  ss.${ShoppingSessionColumns.marketId} AS market_id,
  ss.${ShoppingSessionColumns.marketNameSnapshot} AS market_name,
  si.${ShoppingItemColumns.quantity} AS quantity,
  si.${ShoppingItemColumns.uom} AS uom,
  si.${ShoppingItemColumns.unitPrice} AS unit_price,
  si.${ShoppingItemColumns.lineTotal} AS line_total
FROM ${DatabaseTables.shoppingItems} si
INNER JOIN ${DatabaseTables.shoppingSessions} ss
  ON ss.${ShoppingSessionColumns.id} = si.${ShoppingItemColumns.sessionId}
WHERE ss.${ShoppingSessionColumns.status} = ?
  AND ss.${ShoppingSessionColumns.completedAt} >= ?
  AND ss.${ShoppingSessionColumns.completedAt} < ?
''',
      [ShoppingSessionStatusValues.completed, fromInclusive, toExclusive],
    );
    return rows
        .map(
          (row) => ItemSpendFact(
            productId: row['product_id']! as String,
            productName: row['product_name']! as String,
            marketId: row['market_id']! as String,
            marketName: row['market_name']! as String,
            quantity: Quantity.milli(
              ((row['quantity'] as num).toDouble() * 1000).round(),
            ),
            uom: UnitOfMeasure.fromStorage(row['uom']! as String),
            unitPrice: Money.cents(
              ((row['unit_price'] as num).toDouble() * 100).round(),
            ),
            lineTotal: Money.cents(
              ((row['line_total'] as num).toDouble() * 100).round(),
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<Map<String, Money>> _minUnitPrices(
    DatabaseExecutor db,
    int untilExclusive,
  ) async {
    final rows = await db.rawQuery(
      '''
SELECT
  si.${ShoppingItemColumns.productId} AS product_id,
  MIN(si.${ShoppingItemColumns.unitPrice}) AS min_price
FROM ${DatabaseTables.shoppingItems} si
INNER JOIN ${DatabaseTables.shoppingSessions} ss
  ON ss.${ShoppingSessionColumns.id} = si.${ShoppingItemColumns.sessionId}
WHERE ss.${ShoppingSessionColumns.status} = ?
  AND ss.${ShoppingSessionColumns.completedAt} < ?
GROUP BY si.${ShoppingItemColumns.productId}
''',
      [ShoppingSessionStatusValues.completed, untilExclusive],
    );
    return {
      for (final row in rows)
        row['product_id']! as String: Money.cents(
          ((row['min_price'] as num).toDouble() * 100).round(),
        ),
    };
  }

  Future<Map<String, int>> _itemCounts(
    DatabaseExecutor db,
    int untilExclusive,
  ) async {
    final rows = await db.rawQuery(
      '''
SELECT
  si.${ShoppingItemColumns.productId} AS product_id,
  COUNT(*) AS item_count
FROM ${DatabaseTables.shoppingItems} si
INNER JOIN ${DatabaseTables.shoppingSessions} ss
  ON ss.${ShoppingSessionColumns.id} = si.${ShoppingItemColumns.sessionId}
WHERE ss.${ShoppingSessionColumns.status} = ?
  AND ss.${ShoppingSessionColumns.completedAt} < ?
GROUP BY si.${ShoppingItemColumns.productId}
''',
      [ShoppingSessionStatusValues.completed, untilExclusive],
    );
    return {
      for (final row in rows)
        row['product_id']! as String: (row['item_count'] as num).toInt(),
    };
  }
}
