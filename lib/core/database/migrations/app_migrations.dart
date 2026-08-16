import 'package:home_market_tracker/core/database/migrations/migration_v1.dart';
import 'package:home_market_tracker/core/database/migrations/migration_v2.dart';
import 'package:home_market_tracker/core/database/migrations/migration_v3.dart';
import 'package:home_market_tracker/core/database/migrations/migration_v4.dart';
import 'package:home_market_tracker/core/database/migrations/migration_v5.dart';
import 'package:home_market_tracker/core/database/migrations/migration_v6.dart';
import 'package:sqflite/sqflite.dart';

abstract final class AppMigrations {
  static const schemaVersion = MigrationV6.version;

  static Future<void> onCreate(DatabaseExecutor db) async {
    await MigrationV1.apply(db);
    await MigrationV2.apply(db);
    await MigrationV3.apply(db);
    await MigrationV4.apply(db);
    await MigrationV5.apply(db);
    await MigrationV6.apply(db);
  }

  static Future<void> onUpgrade(
    DatabaseExecutor db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await MigrationV2.apply(db);
    }
    if (oldVersion < 3) {
      await MigrationV3.apply(db);
    }
    if (oldVersion < 4) {
      await MigrationV4.apply(db);
    }
    if (oldVersion < 5) {
      await MigrationV5.apply(db);
    }
    if (oldVersion < 6) {
      await MigrationV6.apply(db);
    }
  }
}
