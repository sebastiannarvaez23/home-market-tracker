import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:sqflite/sqflite.dart';

abstract final class MigrationV2 {
  static const version = 2;

  static Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
ALTER TABLE ${DatabaseTables.shoppingItems}
ADD COLUMN ${ShoppingItemColumns.uom} TEXT NOT NULL DEFAULT '${UnitOfMeasure.unit.code}'
''');
  }
}
