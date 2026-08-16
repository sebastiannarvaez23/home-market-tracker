import 'package:home_market_tracker/core/database/repository_guard.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/shopping/data/datasources/shopping_local_data_source.dart';
import 'package:home_market_tracker/features/shopping/data/models/shopping_models.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  ShoppingRepositoryImpl(this._dataSource);

  final ShoppingLocalDataSource _dataSource;

  @override
  Future<Result<ShoppingSession?>> findInProgress() {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.findInProgress();
      return model?.toEntity();
    });
  }

  @override
  Future<Result<ShoppingMarketRef>> getMarket(String id) {
    return RepositoryGuard.run(() => _dataSource.getMarket(id));
  }

  @override
  Future<Result<ShoppingProductRef>> getProduct(String id) {
    return RepositoryGuard.run(() => _dataSource.getProduct(id));
  }

  @override
  Future<Result<List<ShoppingProductRef>>> listActiveProducts({
    String? nameQuery,
  }) {
    return RepositoryGuard.run(
      () => _dataSource.listActiveProducts(nameQuery: nameQuery),
    );
  }

  @override
  Future<Result<ShoppingSession>> insertSession(ShoppingSession session) {
    return RepositoryGuard.run(() async {
      final model =
          await _dataSource.insertSession(ShoppingSessionModel.fromEntity(session));
      return model.toEntity();
    });
  }

  @override
  Future<Result<ShoppingSession>> upsertItem({
    required String sessionId,
    required ShoppingItem item,
  }) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.upsertItem(
        sessionId: sessionId,
        item: ShoppingItemModel.fromEntity(item),
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<ShoppingSession>> removeItem({
    required String sessionId,
    required String itemId,
  }) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.removeItem(
        sessionId: sessionId,
        itemId: itemId,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<ShoppingSession>> complete({
    required String sessionId,
    required int completedAt,
  }) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.complete(
        sessionId: sessionId,
        completedAt: completedAt,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<void>> deleteInProgress(String sessionId) {
    return RepositoryGuard.run(() => _dataSource.deleteInProgress(sessionId));
  }
}
