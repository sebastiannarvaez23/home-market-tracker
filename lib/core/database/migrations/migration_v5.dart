import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:sqflite/sqflite.dart';

abstract final class MigrationV5 {
  static const version = 5;

  static Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
ALTER TABLE ${DatabaseTables.products}
ADD COLUMN ${ProductColumns.isSuggested} INTEGER NOT NULL DEFAULT 0
''');
    await db.execute(
      'CREATE INDEX idx_products_is_suggested ON ${DatabaseTables.products}(${ProductColumns.isSuggested})',
    );
  }
}
