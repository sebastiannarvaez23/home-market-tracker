import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/database/database_tables.dart';
import 'package:home_market_tracker/core/error/app_exception.dart';
import 'package:home_market_tracker/features/history/data/models/history_models.dart';
import 'package:home_market_tracker/features/history/domain/repositories/history_repository.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryEntryModel>> listCompleted(HistoryFilter filter);

  Future<HistoryDetailModel> getDetail(String sessionId);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  HistoryLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<HistoryEntryModel>> listCompleted(HistoryFilter filter) async {
    final db = await _database.connection;
    final where = StringBuffer(
      'ss.${ShoppingSessionColumns.status} = ?',
    );
    final args = <Object?>[ShoppingSessionStatusValues.completed];

    if (filter.marketId != null && filter.marketId!.isNotEmpty) {
      where.write(' AND ss.${ShoppingSessionColumns.marketId} = ?');
      args.add(filter.marketId);
    }
    if (filter.fromCompletedAtInclusive != null) {
      where.write(' AND ss.${ShoppingSessionColumns.completedAt} >= ?');
      args.add(filter.fromCompletedAtInclusive);
    }
    if (filter.toCompletedAtExclusive != null) {
      where.write(' AND ss.${ShoppingSessionColumns.completedAt} < ?');
      args.add(filter.toCompletedAtExclusive);
    }

    final rows = await db.rawQuery(
      '''
SELECT
  ss.${ShoppingSessionColumns.id} AS ${ShoppingSessionColumns.id},
  ss.${ShoppingSessionColumns.marketId} AS ${ShoppingSessionColumns.marketId},
  ss.${ShoppingSessionColumns.marketNameSnapshot} AS ${ShoppingSessionColumns.marketNameSnapshot},
  ss.${ShoppingSessionColumns.completedAt} AS ${ShoppingSessionColumns.completedAt},
  ss.${ShoppingSessionColumns.totalAmount} AS ${ShoppingSessionColumns.totalAmount},
  COUNT(si.${ShoppingItemColumns.id}) AS item_count
FROM ${DatabaseTables.shoppingSessions} ss
LEFT JOIN ${DatabaseTables.shoppingItems} si
  ON si.${ShoppingItemColumns.sessionId} = ss.${ShoppingSessionColumns.id}
WHERE $where
GROUP BY
  ss.${ShoppingSessionColumns.id},
  ss.${ShoppingSessionColumns.marketId},
  ss.${ShoppingSessionColumns.marketNameSnapshot},
  ss.${ShoppingSessionColumns.completedAt},
  ss.${ShoppingSessionColumns.totalAmount}
ORDER BY ss.${ShoppingSessionColumns.completedAt} DESC
''',
      args,
    );
    return rows.map(HistoryEntryModel.fromMap).toList(growable: false);
  }

  @override
  Future<HistoryDetailModel> getDetail(String sessionId) async {
    final db = await _database.connection;
    final sessions = await db.query(
      DatabaseTables.shoppingSessions,
      columns: const [
        ShoppingSessionColumns.id,
        ShoppingSessionColumns.marketId,
        ShoppingSessionColumns.marketNameSnapshot,
        ShoppingSessionColumns.status,
        ShoppingSessionColumns.completedAt,
        ShoppingSessionColumns.totalAmount,
      ],
      where: '${ShoppingSessionColumns.id} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (sessions.isEmpty) {
      throw const NotFoundException('La compra no existe.');
    }
    final session = sessions.first;
    if (session[ShoppingSessionColumns.status] !=
            ShoppingSessionStatusValues.completed ||
        session[ShoppingSessionColumns.completedAt] == null) {
      throw const PreconditionException(
        'Solo se pueden consultar compras completadas.',
      );
    }

    final itemRows = await db.query(
      DatabaseTables.shoppingItems,
      columns: const [
        ShoppingItemColumns.id,
        ShoppingItemColumns.productId,
        ShoppingItemColumns.productNameSnapshot,
        ShoppingItemColumns.quantity,
        ShoppingItemColumns.uom,
        ShoppingItemColumns.uomFactor,
        ShoppingItemColumns.unitPrice,
        ShoppingItemColumns.lineTotal,
      ],
      where: '${ShoppingItemColumns.sessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${ShoppingItemColumns.productNameSnapshot} COLLATE NOCASE ASC',
    );

    return HistoryDetailModel(
      id: session[ShoppingSessionColumns.id]! as String,
      marketId: session[ShoppingSessionColumns.marketId]! as String,
      marketNameSnapshot:
          session[ShoppingSessionColumns.marketNameSnapshot]! as String,
      completedAt: session[ShoppingSessionColumns.completedAt]! as int,
      totalAmount: (session[ShoppingSessionColumns.totalAmount] as num).toDouble(),
      lines: itemRows.map(HistoryLineModel.fromMap).toList(growable: false),
    );
  }
}
