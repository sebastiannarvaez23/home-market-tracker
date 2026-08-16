import 'package:home_market_tracker/core/database/migrations/app_migrations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef DatabasePathResolver = Future<String> Function();

class AppDatabase {
  AppDatabase({
    required this.pathResolver,
    DatabaseFactory? factory,
  }) : _factory = factory;

  final DatabasePathResolver pathResolver;
  final DatabaseFactory? _factory;
  Database? _database;

  static const fileName = 'home_market_tracker.db';
  static const schemaVersion = AppMigrations.schemaVersion;

  DatabaseFactory get _databaseFactory => _factory ?? databaseFactory;

  Future<Database> get connection async {
    final existing = _database;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    final opened = await _databaseFactory.openDatabase(
      await pathResolver(),
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) => AppMigrations.onCreate(db),
        onUpgrade: AppMigrations.onUpgrade,
        onOpen: (db) async {
          await db.rawQuery('PRAGMA journal_mode = WAL');
        },
      ),
    );
    _database = opened;
    return opened;
  }

  Future<void> close() async {
    final existing = _database;
    if (existing != null && existing.isOpen) {
      await existing.close();
    }
    _database = null;
  }

  static Future<String> documentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, fileName);
  }
}
