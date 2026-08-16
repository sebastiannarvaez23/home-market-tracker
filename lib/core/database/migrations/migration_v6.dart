import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:sqflite/sqflite.dart';

abstract final class MigrationV6 {
  static const version = 6;

  static Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
ALTER TABLE ${DatabaseTables.products}
ADD COLUMN ${ProductColumns.photoPath} TEXT
''');
  }
}
