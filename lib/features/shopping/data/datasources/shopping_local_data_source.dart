import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/error/app_exception.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/shopping/data/models/shopping_models.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:sqflite/sqflite.dart';

abstract class ShoppingLocalDataSource {
  Future<ShoppingSessionModel?> findInProgress();

  Future<ShoppingMarketRef> getMarket(String id);

  Future<ShoppingProductRef> getProduct(String id);

  Future<List<ShoppingProductRef>> listActiveProducts({String? nameQuery});

  Future<ShoppingSessionModel> insertSession(ShoppingSessionModel session);

  Future<ShoppingSessionModel> upsertItem({
    required String sessionId,
    required ShoppingItemModel item,
  });

  Future<ShoppingSessionModel> removeItem({
    required String sessionId,
    required String itemId,
  });

  Future<ShoppingSessionModel> complete({
    required String sessionId,
    required int completedAt,
  });

  Future<void> deleteInProgress(String sessionId);
}

class ShoppingLocalDataSourceImpl implements ShoppingLocalDataSource {
  ShoppingLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  static const _sessionColumns = [
    ShoppingSessionColumns.id,
    ShoppingSessionColumns.marketId,
    ShoppingSessionColumns.marketNameSnapshot,
    ShoppingSessionColumns.status,
    ShoppingSessionColumns.startedAt,
    ShoppingSessionColumns.completedAt,
    ShoppingSessionColumns.totalAmount,
  ];

  static const _itemColumns = [
    ShoppingItemColumns.id,
    ShoppingItemColumns.sessionId,
    ShoppingItemColumns.productId,
    ShoppingItemColumns.productNameSnapshot,
    ShoppingItemColumns.quantity,
    ShoppingItemColumns.uom,
    ShoppingItemColumns.uomFactor,
    ShoppingItemColumns.unitPrice,
    ShoppingItemColumns.lineTotal,
  ];

  @override
  Future<ShoppingSessionModel?> findInProgress() async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.shoppingSessions,
      columns: _sessionColumns,
      where: '${ShoppingSessionColumns.status} = ?',
      whereArgs: [ShoppingSessionStatusValues.inProgress],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final items = await _itemsFor(db, rows.first[ShoppingSessionColumns.id]! as String);
    return ShoppingSessionModel.fromMap(rows.first, items: items);
  }

  @override
  Future<ShoppingMarketRef> getMarket(String id) async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.markets,
      columns: const [
        MarketColumns.id,
        MarketColumns.name,
        MarketColumns.isActive,
      ],
      where: '${MarketColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const NotFoundException('El mercado no existe.');
    }
    final row = rows.first;
    return ShoppingMarketRef(
      id: row[MarketColumns.id]! as String,
      name: row[MarketColumns.name]! as String,
      isActive: (row[MarketColumns.isActive] as int) == 1,
    );
  }

  @override
  Future<ShoppingProductRef> getProduct(String id) async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.products,
      columns: const [
        ProductColumns.id,
        ProductColumns.name,
        ProductColumns.isActive,
        ProductColumns.baseUom,
        ProductColumns.isSuggested,
        ProductColumns.photoPath,
      ],
      where: '${ProductColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const NotFoundException('El producto no existe.');
    }
    final row = rows.first;
    return ShoppingProductRef(
      id: row[ProductColumns.id]! as String,
      name: row[ProductColumns.name]! as String,
      isActive: (row[ProductColumns.isActive] as int) == 1,
      isSuggested: (row[ProductColumns.isSuggested] as int?) == 1,
      photoPath: row[ProductColumns.photoPath] as String?,
      uomLadder: await _ladderFor(
        db,
        row[ProductColumns.id]! as String,
        (row[ProductColumns.baseUom] as String?) ?? UnitOfMeasure.unit.code,
      ),
    );
  }

  @override
  Future<List<ShoppingProductRef>> listActiveProducts({String? nameQuery}) async {
    final db = await _database.connection;
    final hasQuery = nameQuery != null && nameQuery.isNotEmpty;
    final rows = await db.query(
      DatabaseTables.products,
      columns: const [
        ProductColumns.id,
        ProductColumns.name,
        ProductColumns.isActive,
        ProductColumns.baseUom,
        ProductColumns.isSuggested,
        ProductColumns.photoPath,
      ],
      where: hasQuery
          ? '${ProductColumns.isActive} = 1 AND ${ProductColumns.nameNormalized} LIKE ?'
          : '${ProductColumns.isActive} = 1',
      whereArgs: hasQuery ? ['%$nameQuery%'] : null,
      orderBy:
          '${ProductColumns.isSuggested} DESC, ${ProductColumns.name} COLLATE NOCASE ASC',
    );
    if (rows.isEmpty) return const [];

    final ids = [
      for (final row in rows) row[ProductColumns.id]! as String,
    ];
    final placeholders = List.filled(ids.length, '?').join(',');
    final stepRows = await db.query(
      DatabaseTables.productUomSteps,
      columns: const [
        ProductUomStepColumns.productId,
        ProductUomStepColumns.uom,
        ProductUomStepColumns.factor,
        ProductUomStepColumns.sortOrder,
      ],
      where: '${ProductUomStepColumns.productId} IN ($placeholders)',
      whereArgs: ids,
      orderBy: '${ProductUomStepColumns.sortOrder} ASC',
    );
    final stepsByProduct = <String, List<UomLadderStep>>{};
    for (final row in stepRows) {
      final productId = row[ProductUomStepColumns.productId]! as String;
      (stepsByProduct[productId] ??= []).add(
        UomLadderStep(
          uom: UnitOfMeasure.fromStorage(
            row[ProductUomStepColumns.uom]! as String,
          ),
          factor: Quantity.milli(
            ((row[ProductUomStepColumns.factor] as num).toDouble() * 1000)
                .round(),
          ),
        ),
      );
    }

    return [
      for (final row in rows)
        ShoppingProductRef(
          id: row[ProductColumns.id]! as String,
          name: row[ProductColumns.name]! as String,
          isActive: (row[ProductColumns.isActive] as int) == 1,
          isSuggested: (row[ProductColumns.isSuggested] as int?) == 1,
          photoPath: row[ProductColumns.photoPath] as String?,
          uomLadder: UomLadder(
            base: UnitOfMeasure.fromStorage(
              (row[ProductColumns.baseUom] as String?) ??
                  UnitOfMeasure.unit.code,
            ),
            steps: stepsByProduct[row[ProductColumns.id]! as String] ?? const [],
          ),
        ),
    ];
  }

  @override
  Future<ShoppingSessionModel> insertSession(ShoppingSessionModel session) async {
    final db = await _database.connection;
    await db.insert(
      DatabaseTables.shoppingSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return session;
  }

  @override
  Future<ShoppingSessionModel> upsertItem({
    required String sessionId,
    required ShoppingItemModel item,
  }) async {
    final db = await _database.connection;
    return db.transaction((txn) async {
      await _assertInProgress(txn, sessionId);
      await txn.rawInsert(
        '''
INSERT INTO ${DatabaseTables.shoppingItems} (
  ${ShoppingItemColumns.id},
  ${ShoppingItemColumns.sessionId},
  ${ShoppingItemColumns.productId},
  ${ShoppingItemColumns.productNameSnapshot},
  ${ShoppingItemColumns.quantity},
  ${ShoppingItemColumns.uom},
  ${ShoppingItemColumns.uomFactor},
  ${ShoppingItemColumns.unitPrice},
  ${ShoppingItemColumns.lineTotal}
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(${ShoppingItemColumns.sessionId}, ${ShoppingItemColumns.productId})
DO UPDATE SET
  ${ShoppingItemColumns.productNameSnapshot} = excluded.${ShoppingItemColumns.productNameSnapshot},
  ${ShoppingItemColumns.quantity} = excluded.${ShoppingItemColumns.quantity},
  ${ShoppingItemColumns.uom} = excluded.${ShoppingItemColumns.uom},
  ${ShoppingItemColumns.uomFactor} = excluded.${ShoppingItemColumns.uomFactor},
  ${ShoppingItemColumns.unitPrice} = excluded.${ShoppingItemColumns.unitPrice},
  ${ShoppingItemColumns.lineTotal} = excluded.${ShoppingItemColumns.lineTotal}
''',
        [
          item.id,
          item.sessionId,
          item.productId,
          item.productNameSnapshot,
          item.quantity,
          item.uom,
          item.uomFactor,
          item.unitPrice,
          item.lineTotal,
        ],
      );
      await _recalculateTotal(txn, sessionId);
      return _loadSession(txn, sessionId);
    });
  }

  @override
  Future<ShoppingSessionModel> removeItem({
    required String sessionId,
    required String itemId,
  }) async {
    final db = await _database.connection;
    return db.transaction((txn) async {
      await _assertInProgress(txn, sessionId);
      final deleted = await txn.delete(
        DatabaseTables.shoppingItems,
        where:
            '${ShoppingItemColumns.id} = ? AND ${ShoppingItemColumns.sessionId} = ?',
        whereArgs: [itemId, sessionId],
      );
      if (deleted == 0) {
        throw const NotFoundException('El producto no está en la compra actual.');
      }
      await _recalculateTotal(txn, sessionId);
      return _loadSession(txn, sessionId);
    });
  }

  @override
  Future<ShoppingSessionModel> complete({
    required String sessionId,
    required int completedAt,
  }) async {
    final db = await _database.connection;
    return db.transaction((txn) async {
      await _assertInProgress(txn, sessionId);
      final count = Sqflite.firstIntValue(
            await txn.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseTables.shoppingItems} WHERE ${ShoppingItemColumns.sessionId} = ?',
              [sessionId],
            ),
          ) ??
          0;
      if (count == 0) {
        throw const PreconditionException(
          'No se puede completar una compra sin productos.',
        );
      }
      final total = await _sumItems(txn, sessionId);
      await txn.update(
        DatabaseTables.shoppingSessions,
        {
          ShoppingSessionColumns.status: ShoppingSessionStatusValues.completed,
          ShoppingSessionColumns.completedAt: completedAt,
          ShoppingSessionColumns.totalAmount: total,
        },
        where: '${ShoppingSessionColumns.id} = ?',
        whereArgs: [sessionId],
      );
      await txn.rawUpdate(
        '''
UPDATE ${DatabaseTables.products}
SET ${ProductColumns.isSuggested} = 0
WHERE ${ProductColumns.isSuggested} = 1
  AND ${ProductColumns.id} IN (
    SELECT ${ShoppingItemColumns.productId}
    FROM ${DatabaseTables.shoppingItems}
    WHERE ${ShoppingItemColumns.sessionId} = ?
  )
''',
        [sessionId],
      );
      return _loadSession(txn, sessionId);
    });
  }

  @override
  Future<void> deleteInProgress(String sessionId) async {
    final db = await _database.connection;
    await db.transaction((txn) async {
      await _assertInProgress(txn, sessionId);
      await txn.delete(
        DatabaseTables.shoppingSessions,
        where:
            '${ShoppingSessionColumns.id} = ? AND ${ShoppingSessionColumns.status} = ?',
        whereArgs: [sessionId, ShoppingSessionStatusValues.inProgress],
      );
    });
  }

  Future<void> _assertInProgress(DatabaseExecutor txn, String sessionId) async {
    final rows = await txn.query(
      DatabaseTables.shoppingSessions,
      columns: const [ShoppingSessionColumns.id, ShoppingSessionColumns.status],
      where: '${ShoppingSessionColumns.id} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const NotFoundException('No hay una compra en curso.');
    }
    if (rows.first[ShoppingSessionColumns.status] !=
        ShoppingSessionStatusValues.inProgress) {
      throw const PreconditionException(
        'Solo se puede modificar una compra en curso.',
      );
    }
  }

  Future<void> _recalculateTotal(DatabaseExecutor txn, String sessionId) async {
    final total = await _sumItems(txn, sessionId);
    await txn.update(
      DatabaseTables.shoppingSessions,
      {ShoppingSessionColumns.totalAmount: total},
      where: '${ShoppingSessionColumns.id} = ?',
      whereArgs: [sessionId],
    );
  }

  Future<double> _sumItems(DatabaseExecutor txn, String sessionId) async {
    final rows = await txn.rawQuery(
      'SELECT COALESCE(SUM(${ShoppingItemColumns.lineTotal}), 0) AS total FROM ${DatabaseTables.shoppingItems} WHERE ${ShoppingItemColumns.sessionId} = ?',
      [sessionId],
    );
    return (rows.first['total'] as num).toDouble();
  }

  Future<ShoppingSessionModel> _loadSession(
    DatabaseExecutor txn,
    String sessionId,
  ) async {
    final rows = await txn.query(
      DatabaseTables.shoppingSessions,
      columns: _sessionColumns,
      where: '${ShoppingSessionColumns.id} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const NotFoundException('La compra no existe.');
    }
    final items = await _itemsFor(txn, sessionId);
    return ShoppingSessionModel.fromMap(rows.first, items: items);
  }

  Future<List<ShoppingItemModel>> _itemsFor(
    DatabaseExecutor txn,
    String sessionId,
  ) async {
    final rows = await txn.query(
      DatabaseTables.shoppingItems,
      columns: _itemColumns,
      where: '${ShoppingItemColumns.sessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${ShoppingItemColumns.productNameSnapshot} COLLATE NOCASE ASC',
    );
    return rows.map(ShoppingItemModel.fromMap).toList(growable: false);
  }

  Future<UomLadder> _ladderFor(
    DatabaseExecutor db,
    String productId,
    String baseUom,
  ) async {
    final rows = await db.query(
      DatabaseTables.productUomSteps,
      columns: const [
        ProductUomStepColumns.uom,
        ProductUomStepColumns.factor,
        ProductUomStepColumns.sortOrder,
      ],
      where: '${ProductUomStepColumns.productId} = ?',
      whereArgs: [productId],
      orderBy: '${ProductUomStepColumns.sortOrder} ASC',
    );
    return UomLadder(
      base: UnitOfMeasure.fromStorage(baseUom),
      steps: rows
          .map(
            (row) => UomLadderStep(
              uom: UnitOfMeasure.fromStorage(
                row[ProductUomStepColumns.uom]! as String,
              ),
              factor: Quantity.milli(
                ((row[ProductUomStepColumns.factor] as num).toDouble() * 1000)
                    .round(),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
