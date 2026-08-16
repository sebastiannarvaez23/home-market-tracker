import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:sqflite/sqflite.dart';

abstract final class MigrationV4 {
  static const version = 4;

  static Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
CREATE TABLE ${DatabaseTables.productUomSteps}_v4 (
  ${ProductUomStepColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${ProductUomStepColumns.productId} TEXT NOT NULL,
  ${ProductUomStepColumns.uom} TEXT NOT NULL,
  ${ProductUomStepColumns.factor} REAL NOT NULL,
  ${ProductUomStepColumns.sortOrder} INTEGER NOT NULL,
  UNIQUE (
    ${ProductUomStepColumns.productId},
    ${ProductUomStepColumns.uom},
    ${ProductUomStepColumns.factor}
  ),
  UNIQUE (
    ${ProductUomStepColumns.productId},
    ${ProductUomStepColumns.sortOrder}
  ),
  FOREIGN KEY (${ProductUomStepColumns.productId})
    REFERENCES ${DatabaseTables.products}(${ProductColumns.id})
)
''');
    await db.execute('''
INSERT INTO ${DatabaseTables.productUomSteps}_v4 (
  ${ProductUomStepColumns.id},
  ${ProductUomStepColumns.productId},
  ${ProductUomStepColumns.uom},
  ${ProductUomStepColumns.factor},
  ${ProductUomStepColumns.sortOrder}
)
SELECT
  ${ProductUomStepColumns.id},
  ${ProductUomStepColumns.productId},
  ${ProductUomStepColumns.uom},
  ${ProductUomStepColumns.factor},
  ${ProductUomStepColumns.sortOrder}
FROM ${DatabaseTables.productUomSteps}
''');
    await db.execute('DROP TABLE ${DatabaseTables.productUomSteps}');
    await db.execute(
      'ALTER TABLE ${DatabaseTables.productUomSteps}_v4 RENAME TO ${DatabaseTables.productUomSteps}',
    );
    await db.execute(
      'CREATE INDEX idx_product_uom_steps_product_id ON ${DatabaseTables.productUomSteps}(${ProductUomStepColumns.productId})',
    );

    await db.execute('''
ALTER TABLE ${DatabaseTables.shoppingItems}
ADD COLUMN ${ShoppingItemColumns.uomFactor} REAL NOT NULL DEFAULT 1
''');
  }
}
