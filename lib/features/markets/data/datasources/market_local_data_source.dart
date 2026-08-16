import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/error/app_exception.dart';
import 'package:home_market_tracker/features/markets/data/models/market_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class MarketLocalDataSource {
  Future<List<MarketModel>> listActive({String? query});

  Future<MarketModel> getById(String id);

  Future<MarketModel?> findByNormalizedName(String nameNormalized);

  Future<MarketModel> insert(MarketModel market);

  Future<MarketModel> update(MarketModel market);
}

class MarketLocalDataSourceImpl implements MarketLocalDataSource {
  MarketLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  static const _columns = [
    MarketColumns.id,
    MarketColumns.name,
    MarketColumns.nameNormalized,
    MarketColumns.location,
    MarketColumns.notes,
    MarketColumns.isActive,
    MarketColumns.createdAt,
    MarketColumns.updatedAt,
  ];

  @override
  Future<List<MarketModel>> listActive({String? query}) async {
    final db = await _database.connection;
    final hasQuery = query != null && query.isNotEmpty;
    final rows = await db.query(
      DatabaseTables.markets,
      columns: _columns,
      where: hasQuery
          ? '${MarketColumns.isActive} = 1 AND (${MarketColumns.nameNormalized} LIKE ? OR IFNULL(${MarketColumns.location}, \'\') LIKE ?)'
          : '${MarketColumns.isActive} = 1',
      whereArgs: hasQuery ? ['%$query%', '%$query%'] : null,
      orderBy: '${MarketColumns.name} COLLATE NOCASE ASC',
    );
    return rows.map(MarketModel.fromMap).toList(growable: false);
  }

  @override
  Future<MarketModel> getById(String id) async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.markets,
      columns: _columns,
      where: '${MarketColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const NotFoundException('El mercado no existe.');
    }
    return MarketModel.fromMap(rows.first);
  }

  @override
  Future<MarketModel?> findByNormalizedName(String nameNormalized) async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.markets,
      columns: _columns,
      where: '${MarketColumns.nameNormalized} = ?',
      whereArgs: [nameNormalized],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MarketModel.fromMap(rows.first);
  }

  @override
  Future<MarketModel> insert(MarketModel market) async {
    final db = await _database.connection;
    await db.insert(
      DatabaseTables.markets,
      market.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return market;
  }

  @override
  Future<MarketModel> update(MarketModel market) async {
    final db = await _database.connection;
    final updated = await db.update(
      DatabaseTables.markets,
      market.toMap(),
      where: '${MarketColumns.id} = ?',
      whereArgs: [market.id],
    );
    if (updated == 0) {
      throw const NotFoundException('El mercado no existe.');
    }
    return market;
  }
}
