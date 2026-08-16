import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:sqflite/sqflite.dart';

abstract final class MigrationV3 {
  static const version = 3;

  static Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
ALTER TABLE ${DatabaseTables.products}
ADD COLUMN ${ProductColumns.baseUom} TEXT NOT NULL DEFAULT 'Und'
''');
    await db.execute('''
CREATE TABLE ${DatabaseTables.productUomSteps} (
  ${ProductUomStepColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${ProductUomStepColumns.productId} TEXT NOT NULL,
  ${ProductUomStepColumns.uom} TEXT NOT NULL,
  ${ProductUomStepColumns.factor} REAL NOT NULL,
  ${ProductUomStepColumns.sortOrder} INTEGER NOT NULL,
  UNIQUE (${ProductUomStepColumns.productId}, ${ProductUomStepColumns.uom}),
  UNIQUE (${ProductUomStepColumns.productId}, ${ProductUomStepColumns.sortOrder}),
  FOREIGN KEY (${ProductUomStepColumns.productId})
    REFERENCES ${DatabaseTables.products}(${ProductColumns.id})
)
''');
    await db.execute(
      'CREATE INDEX idx_product_uom_steps_product_id ON ${DatabaseTables.productUomSteps}(${ProductUomStepColumns.productId})',
    );
  }
}
