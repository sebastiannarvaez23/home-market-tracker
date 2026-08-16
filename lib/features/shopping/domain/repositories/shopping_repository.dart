import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';

abstract class ShoppingRepository {
  Future<Result<ShoppingSession?>> findInProgress();

  Future<Result<ShoppingMarketRef>> getMarket(String id);

  Future<Result<ShoppingProductRef>> getProduct(String id);

  Future<Result<List<ShoppingProductRef>>> listActiveProducts({
    String? nameQuery,
  });

  Future<Result<ShoppingSession>> insertSession(ShoppingSession session);

  Future<Result<ShoppingSession>> upsertItem({
    required String sessionId,
    required ShoppingItem item,
  });

  Future<Result<ShoppingSession>> removeItem({
    required String sessionId,
    required String itemId,
  });

  Future<Result<ShoppingSession>> complete({
    required String sessionId,
    required int completedAt,
  });

  Future<Result<void>> deleteInProgress(String sessionId);
}
