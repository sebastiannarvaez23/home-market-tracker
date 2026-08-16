import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/error/app_exception.dart';
import 'package:home_market_tracker/features/products/data/models/product_model.dart';
import 'package:home_market_tracker/features/products/data/models/product_purchase_history_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> listActive({String? nameQuery});

  Future<List<ProductModel>> listActiveWithLastPurchase({String? nameQuery});

  Future<ProductModel> getById(String id);

  Future<ProductModel?> findByNormalizedName(String nameNormalized);

  Future<ProductModel> insert(ProductModel product);

  Future<ProductModel> update(ProductModel product);

  Future<List<ProductPurchaseHistoryModel>> listPurchaseHistory(String productId);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  static const _productColumns = [
    ProductColumns.id,
    ProductColumns.name,
    ProductColumns.nameNormalized,
    ProductColumns.notes,
    ProductColumns.isActive,
    ProductColumns.createdAt,
    ProductColumns.updatedAt,
    ProductColumns.baseUom,
    ProductColumns.isSuggested,
    ProductColumns.photoPath,
  ];

  @override
  Future<List<ProductModel>> listActive({String? nameQuery}) async {
    final db = await _database.connection;
    final hasQuery = nameQuery != null && nameQuery.isNotEmpty;
    final rows = await db.query(
      DatabaseTables.products,
      columns: _productColumns,
      where: hasQuery
          ? '${ProductColumns.isActive} = 1 AND ${ProductColumns.nameNormalized} LIKE ?'
          : '${ProductColumns.isActive} = 1',
      whereArgs: hasQuery ? ['%$nameQuery%'] : null,
      orderBy: '${ProductColumns.name} COLLATE NOCASE ASC',
    );
    return _attachLadders(db, rows.map(ProductModel.fromMap).toList());
  }

  @override
  Future<List<ProductModel>> listActiveWithLastPurchase({
    String? nameQuery,
  }) async {
    final db = await _database.connection;
    final hasQuery = nameQuery != null && nameQuery.isNotEmpty;
    final sql = '''
SELECT
  p.${ProductColumns.id} AS ${ProductColumns.id},
  p.${ProductColumns.name} AS ${ProductColumns.name},
  p.${ProductColumns.nameNormalized} AS ${ProductColumns.nameNormalized},
  p.${ProductColumns.notes} AS ${ProductColumns.notes},
  p.${ProductColumns.isActive} AS ${ProductColumns.isActive},
  p.${ProductColumns.createdAt} AS ${ProductColumns.createdAt},
  p.${ProductColumns.updatedAt} AS ${ProductColumns.updatedAt},
  p.${ProductColumns.baseUom} AS ${ProductColumns.baseUom},
  p.${ProductColumns.isSuggested} AS ${ProductColumns.isSuggested},
  p.${ProductColumns.photoPath} AS ${ProductColumns.photoPath},
  lp.${ShoppingSessionColumns.marketNameSnapshot} AS ${LastPurchaseColumns.marketNameSnapshot},
  lp.${ShoppingItemColumns.unitPrice} AS ${LastPurchaseColumns.unitPrice},
  lp.${ShoppingItemColumns.uom} AS ${LastPurchaseColumns.uom},
  lp.${ShoppingItemColumns.uomFactor} AS ${LastPurchaseColumns.uomFactor},
  lp.${ShoppingSessionColumns.completedAt} AS ${LastPurchaseColumns.purchasedAt}
FROM ${DatabaseTables.products} p
LEFT JOIN (
  SELECT
    si.${ShoppingItemColumns.productId} AS product_id,
    ss.${ShoppingSessionColumns.marketNameSnapshot} AS ${ShoppingSessionColumns.marketNameSnapshot},
    si.${ShoppingItemColumns.unitPrice} AS ${ShoppingItemColumns.unitPrice},
    si.${ShoppingItemColumns.uom} AS ${ShoppingItemColumns.uom},
    si.${ShoppingItemColumns.uomFactor} AS ${ShoppingItemColumns.uomFactor},
    ss.${ShoppingSessionColumns.completedAt} AS ${ShoppingSessionColumns.completedAt}
  FROM ${DatabaseTables.shoppingItems} si
  INNER JOIN ${DatabaseTables.shoppingSessions} ss
    ON ss.${ShoppingSessionColumns.id} = si.${ShoppingItemColumns.sessionId}
  INNER JOIN (
    SELECT
      si2.${ShoppingItemColumns.productId} AS product_id,
      MAX(ss2.${ShoppingSessionColumns.completedAt}) AS max_completed_at
    FROM ${DatabaseTables.shoppingItems} si2
    INNER JOIN ${DatabaseTables.shoppingSessions} ss2
      ON ss2.${ShoppingSessionColumns.id} = si2.${ShoppingItemColumns.sessionId}
    WHERE ss2.${ShoppingSessionColumns.status} = ?
    GROUP BY si2.${ShoppingItemColumns.productId}
  ) latest
    ON latest.product_id = si.${ShoppingItemColumns.productId}
   AND latest.max_completed_at = ss.${ShoppingSessionColumns.completedAt}
  WHERE ss.${ShoppingSessionColumns.status} = ?
  GROUP BY si.${ShoppingItemColumns.productId}
) lp ON lp.product_id = p.${ProductColumns.id}
WHERE p.${ProductColumns.isActive} = 1
${hasQuery ? 'AND p.${ProductColumns.nameNormalized} LIKE ?' : ''}
ORDER BY p.${ProductColumns.name} COLLATE NOCASE ASC
''';
    final args = <Object?>[
      ShoppingSessionStatusValues.completed,
      ShoppingSessionStatusValues.completed,
      if (hasQuery) '%$nameQuery%',
    ];
    final rows = await db.rawQuery(sql, args);
    return _attachLadders(db, rows.map(ProductModel.fromMap).toList());
  }

  @override
  Future<ProductModel> getById(String id) async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.products,
      columns: _productColumns,
      where: '${ProductColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const NotFoundException('El producto no existe.');
    }
    final attached = await _attachLadders(db, [ProductModel.fromMap(rows.first)]);
    return attached.single;
  }

  @override
  Future<ProductModel?> findByNormalizedName(String nameNormalized) async {
    final db = await _database.connection;
    final rows = await db.query(
      DatabaseTables.products,
      columns: _productColumns,
      where: '${ProductColumns.nameNormalized} = ?',
      whereArgs: [nameNormalized],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final attached = await _attachLadders(db, [ProductModel.fromMap(rows.first)]);
    return attached.single;
  }

  @override
  Future<ProductModel> insert(ProductModel product) async {
    final db = await _database.connection;
    await db.transaction((txn) async {
      await txn.insert(
        DatabaseTables.products,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _replaceSteps(txn, product);
    });
    return product;
  }

  @override
  Future<ProductModel> update(ProductModel product) async {
    final db = await _database.connection;
    await db.transaction((txn) async {
      final updated = await txn.update(
        DatabaseTables.products,
        product.toMap(),
        where: '${ProductColumns.id} = ?',
        whereArgs: [product.id],
      );
      if (updated == 0) {
        throw const NotFoundException('El producto no existe.');
      }
      await _replaceSteps(txn, product);
    });
    return product;
  }

  @override
  Future<List<ProductPurchaseHistoryModel>> listPurchaseHistory(
    String productId,
  ) async {
    final db = await _database.connection;
    final rows = await db.rawQuery(
      '''
SELECT
  si.${ShoppingItemColumns.id} AS ${ShoppingItemColumns.id},
  ss.${ShoppingSessionColumns.marketNameSnapshot} AS ${ShoppingSessionColumns.marketNameSnapshot},
  si.${ShoppingItemColumns.unitPrice} AS ${ShoppingItemColumns.unitPrice},
  si.${ShoppingItemColumns.quantity} AS ${ShoppingItemColumns.quantity},
  si.${ShoppingItemColumns.uom} AS ${ShoppingItemColumns.uom},
  si.${ShoppingItemColumns.uomFactor} AS ${ShoppingItemColumns.uomFactor},
  ss.${ShoppingSessionColumns.completedAt} AS ${ShoppingSessionColumns.completedAt}
FROM ${DatabaseTables.shoppingItems} si
INNER JOIN ${DatabaseTables.shoppingSessions} ss
  ON ss.${ShoppingSessionColumns.id} = si.${ShoppingItemColumns.sessionId}
WHERE si.${ShoppingItemColumns.productId} = ?
  AND ss.${ShoppingSessionColumns.status} = ?
ORDER BY ss.${ShoppingSessionColumns.completedAt} DESC, si.${ShoppingItemColumns.id} DESC
''',
      [productId, ShoppingSessionStatusValues.completed],
    );
    return rows
        .map(ProductPurchaseHistoryModel.fromMap)
        .toList(growable: false);
  }

  Future<void> _replaceSteps(DatabaseExecutor txn, ProductModel product) async {
    await txn.delete(
      DatabaseTables.productUomSteps,
      where: '${ProductUomStepColumns.productId} = ?',
      whereArgs: [product.id],
    );
    for (final step in product.steps) {
      await txn.insert(DatabaseTables.productUomSteps, {
        ProductUomStepColumns.id: '${product.id}:${step.sortOrder}',
        ProductUomStepColumns.productId: product.id,
        ProductUomStepColumns.uom: step.uom,
        ProductUomStepColumns.factor: step.factor,
        ProductUomStepColumns.sortOrder: step.sortOrder,
      });
    }
  }

  Future<List<ProductModel>> _attachLadders(
    DatabaseExecutor db,
    List<ProductModel> products,
  ) async {
    if (products.isEmpty) return products;
    final ids = products.map((product) => product.id).toList();
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.query(
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
    final byProduct = <String, List<ProductUomStepModel>>{};
    for (final row in rows) {
      final productId = row[ProductUomStepColumns.productId]! as String;
      byProduct.putIfAbsent(productId, () => []).add(
            ProductUomStepModel.fromMap(row),
          );
    }
    return products
        .map((product) => product.withSteps(byProduct[product.id] ?? const []))
        .toList(growable: false);
  }
}
