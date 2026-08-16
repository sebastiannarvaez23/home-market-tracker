import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:sqflite/sqflite.dart';

abstract final class MigrationV1 {
  static const version = 1;

  static Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
CREATE TABLE ${DatabaseTables.products} (
  ${ProductColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${ProductColumns.name} TEXT NOT NULL,
  ${ProductColumns.nameNormalized} TEXT NOT NULL UNIQUE,
  ${ProductColumns.notes} TEXT,
  ${ProductColumns.isActive} INTEGER NOT NULL DEFAULT 1,
  ${ProductColumns.createdAt} INTEGER NOT NULL,
  ${ProductColumns.updatedAt} INTEGER NOT NULL
)
''');
    await db.execute(
      'CREATE INDEX idx_products_is_active ON ${DatabaseTables.products}(${ProductColumns.isActive})',
    );
    await db.execute(
      'CREATE INDEX idx_products_name_normalized ON ${DatabaseTables.products}(${ProductColumns.nameNormalized})',
    );

    await db.execute('''
CREATE TABLE ${DatabaseTables.markets} (
  ${MarketColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${MarketColumns.name} TEXT NOT NULL,
  ${MarketColumns.nameNormalized} TEXT NOT NULL UNIQUE,
  ${MarketColumns.location} TEXT,
  ${MarketColumns.notes} TEXT,
  ${MarketColumns.isActive} INTEGER NOT NULL DEFAULT 1,
  ${MarketColumns.createdAt} INTEGER NOT NULL,
  ${MarketColumns.updatedAt} INTEGER NOT NULL
)
''');
    await db.execute(
      'CREATE INDEX idx_markets_is_active ON ${DatabaseTables.markets}(${MarketColumns.isActive})',
    );
    await db.execute(
      'CREATE INDEX idx_markets_name_normalized ON ${DatabaseTables.markets}(${MarketColumns.nameNormalized})',
    );

    await db.execute('''
CREATE TABLE ${DatabaseTables.shoppingSessions} (
  ${ShoppingSessionColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${ShoppingSessionColumns.marketId} TEXT NOT NULL,
  ${ShoppingSessionColumns.marketNameSnapshot} TEXT NOT NULL,
  ${ShoppingSessionColumns.status} TEXT NOT NULL,
  ${ShoppingSessionColumns.startedAt} INTEGER NOT NULL,
  ${ShoppingSessionColumns.completedAt} INTEGER,
  ${ShoppingSessionColumns.totalAmount} REAL NOT NULL DEFAULT 0,
  FOREIGN KEY (${ShoppingSessionColumns.marketId})
    REFERENCES ${DatabaseTables.markets}(${MarketColumns.id})
)
''');
    await db.execute(
      'CREATE INDEX idx_shopping_sessions_status ON ${DatabaseTables.shoppingSessions}(${ShoppingSessionColumns.status})',
    );
    await db.execute(
      'CREATE INDEX idx_shopping_sessions_completed_at ON ${DatabaseTables.shoppingSessions}(${ShoppingSessionColumns.completedAt})',
    );
    await db.execute(
      'CREATE INDEX idx_shopping_sessions_market_id ON ${DatabaseTables.shoppingSessions}(${ShoppingSessionColumns.marketId})',
    );
    await db.execute('''
CREATE UNIQUE INDEX idx_shopping_sessions_one_in_progress
ON ${DatabaseTables.shoppingSessions}(${ShoppingSessionColumns.status})
WHERE ${ShoppingSessionColumns.status} = '${ShoppingSessionStatusValues.inProgress}'
''');

    await db.execute('''
CREATE TABLE ${DatabaseTables.shoppingItems} (
  ${ShoppingItemColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${ShoppingItemColumns.sessionId} TEXT NOT NULL,
  ${ShoppingItemColumns.productId} TEXT NOT NULL,
  ${ShoppingItemColumns.productNameSnapshot} TEXT NOT NULL,
  ${ShoppingItemColumns.quantity} REAL NOT NULL,
  ${ShoppingItemColumns.unitPrice} REAL NOT NULL,
  ${ShoppingItemColumns.lineTotal} REAL NOT NULL,
  UNIQUE (${ShoppingItemColumns.sessionId}, ${ShoppingItemColumns.productId}),
  FOREIGN KEY (${ShoppingItemColumns.sessionId})
    REFERENCES ${DatabaseTables.shoppingSessions}(${ShoppingSessionColumns.id})
    ON DELETE CASCADE,
  FOREIGN KEY (${ShoppingItemColumns.productId})
    REFERENCES ${DatabaseTables.products}(${ProductColumns.id})
)
''');
    await db.execute(
      'CREATE INDEX idx_shopping_items_product_id ON ${DatabaseTables.shoppingItems}(${ShoppingItemColumns.productId})',
    );
    await db.execute(
      'CREATE INDEX idx_shopping_items_session_id ON ${DatabaseTables.shoppingItems}(${ShoppingItemColumns.sessionId})',
    );
  }
}
