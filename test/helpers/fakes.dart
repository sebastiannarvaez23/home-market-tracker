import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/id/id_generator.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/domain/repositories/history_repository.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_photo_storage.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session_status.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;

  @override
  int nowEpochMs() => now().millisecondsSinceEpoch;
}

class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator(this._ids);

  final List<String> _ids;
  var _index = 0;

  @override
  String next() => _ids[_index++];
}

const testPhotoSourcePath = 'memory://product-photo';

class FakeProductPhotoStorage implements ProductPhotoStorage {
  final saved = <String, String>{};

  @override
  Future<Result<String>> persist({
    required String productId,
    required String sourcePath,
  }) async {
    saved[productId] = sourcePath;
    return Result.success('product_photos/$productId.jpg');
  }
}

class InMemoryProductRepository implements ProductRepository {
  final products = <String, Product>{};
  final lastPurchases = <String, ProductLastPurchase>{};
  final purchaseHistory = <String, List<ProductPurchaseHistoryEntry>>{};

  @override
  Future<Result<List<Product>>> listActive({String? nameQuery}) async {
    final items = products.values.where((product) {
      if (!product.isActive) return false;
      if (nameQuery == null || nameQuery.isEmpty) return true;
      return product.nameNormalized.contains(nameQuery);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Result.success(items);
  }

  @override
  Future<Result<List<ProductWithLastPurchase>>> listActiveWithLastPurchase({
    String? nameQuery,
  }) async {
    final listed = await listActive(nameQuery: nameQuery);
    return listed.map(
      (items) => items
          .map(
            (product) => ProductWithLastPurchase(
              product: product,
              lastPurchase: lastPurchases[product.id],
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Result<Product>> getById(String id) async {
    final product = products[id];
    if (product == null) {
      return const Result.failure(Failure.notFound('El producto no existe.'));
    }
    return Result.success(product);
  }

  @override
  Future<Result<Product?>> findByNormalizedName(String nameNormalized) async {
    for (final product in products.values) {
      if (product.nameNormalized == nameNormalized) {
        return Result.success(product);
      }
    }
    return const Result.success(null);
  }

  @override
  Future<Result<Product>> insert(Product product) async {
    products[product.id] = product;
    return Result.success(product);
  }

  @override
  Future<Result<Product>> update(Product product) async {
    products[product.id] = product;
    return Result.success(product);
  }

  @override
  Future<Result<List<ProductPurchaseHistoryEntry>>> listPurchaseHistory(
    String productId,
  ) async {
    final items = List<ProductPurchaseHistoryEntry>.from(
      purchaseHistory[productId] ?? const [],
    )..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return Result.success(items);
  }
}

class InMemoryShoppingRepository implements ShoppingRepository {
  ShoppingSession? inProgress;
  final markets = <String, ShoppingMarketRef>{};
  final catalogProducts = <String, ShoppingProductRef>{};

  @override
  Future<Result<ShoppingSession?>> findInProgress() async {
    return Result.success(inProgress);
  }

  @override
  Future<Result<ShoppingMarketRef>> getMarket(String id) async {
    final market = markets[id];
    if (market == null) {
      return const Result.failure(Failure.notFound('El mercado no existe.'));
    }
    return Result.success(market);
  }

  @override
  Future<Result<ShoppingProductRef>> getProduct(String id) async {
    final product = catalogProducts[id];
    if (product == null) {
      return const Result.failure(Failure.notFound('El producto no existe.'));
    }
    return Result.success(product);
  }

  @override
  Future<Result<List<ShoppingProductRef>>> listActiveProducts({
    String? nameQuery,
  }) async {
    final items = catalogProducts.values.where((product) {
      if (!product.isActive) return false;
      if (nameQuery == null || nameQuery.isEmpty) return true;
      return product.name.toLowerCase().contains(nameQuery);
    }).toList()
      ..sort((a, b) {
        if (a.isSuggested != b.isSuggested) {
          return a.isSuggested ? -1 : 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return Result.success(items);
  }

  @override
  Future<Result<ShoppingSession>> insertSession(ShoppingSession session) async {
    inProgress = session;
    return Result.success(session);
  }

  @override
  Future<Result<ShoppingSession>> upsertItem({
    required String sessionId,
    required ShoppingItem item,
  }) async {
    final session = inProgress;
    if (session == null || session.id != sessionId) {
      return const Result.failure(
        Failure.precondition('No hay una compra en curso.'),
      );
    }
    final items = [
      ...session.items.where((current) => current.productId != item.productId),
      item,
    ];
    inProgress = session.copyWith(items: items);
    return Result.success(inProgress!);
  }

  @override
  Future<Result<ShoppingSession>> removeItem({
    required String sessionId,
    required String itemId,
  }) async {
    final session = inProgress!;
    inProgress = session.copyWith(
      items: session.items.where((item) => item.id != itemId).toList(),
    );
    return Result.success(inProgress!);
  }

  @override
  Future<Result<ShoppingSession>> complete({
    required String sessionId,
    required int completedAt,
  }) async {
    final session = inProgress!;
    for (final item in session.items) {
      final product = catalogProducts[item.productId];
      if (product != null) {
        catalogProducts[item.productId] = product.copyWith(isSuggested: false);
      }
    }
    inProgress = null;
    return Result.success(
      ShoppingSession(
        id: session.id,
        marketId: session.marketId,
        marketNameSnapshot: session.marketNameSnapshot,
        status: ShoppingSessionStatus.completed,
        startedAt: session.startedAt,
        completedAt: completedAt,
        items: session.items,
      ),
    );
  }

  @override
  Future<Result<void>> deleteInProgress(String sessionId) async {
    inProgress = null;
    return const Result.success(null);
  }
}

class InMemoryDashboardRepository implements DashboardRepository {
  Result<DashboardFacts>? result;

  @override
  Future<Result<DashboardFacts>> loadFacts(DashboardWindow window) async {
    if (result != null) return result!;
    return Result.success(
      DashboardFacts(
        window: window,
        sessionsInPeriod: const [],
        sessionsInPrevious: const [],
        itemsInPeriod: const [],
        minUnitPriceByProductId: const {},
        completedItemCountByProductId: const {},
        trendSessions: const [],
      ),
    );
  }
}

class InMemoryMarketRepository implements MarketRepository {
  final markets = <String, Market>{};

  @override
  Future<Result<List<Market>>> listActive({String? query}) async {
    final items = markets.values.where((market) {
      if (!market.isActive) return false;
      if (query == null || query.isEmpty) return true;
      return market.nameNormalized.contains(query);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Result.success(items);
  }

  @override
  Future<Result<Market>> getById(String id) async {
    final market = markets[id];
    if (market == null) {
      return const Result.failure(Failure.notFound('El mercado no existe.'));
    }
    return Result.success(market);
  }

  @override
  Future<Result<Market?>> findByNormalizedName(String nameNormalized) async {
    for (final market in markets.values) {
      if (market.nameNormalized == nameNormalized) {
        return Result.success(market);
      }
    }
    return const Result.success(null);
  }

  @override
  Future<Result<Market>> insert(Market market) async {
    markets[market.id] = market;
    return Result.success(market);
  }

  @override
  Future<Result<Market>> update(Market market) async {
    markets[market.id] = market;
    return Result.success(market);
  }
}

class InMemoryHistoryRepository implements HistoryRepository {
  var entries = <HistoryEntry>[];
  final details = <String, HistoryDetail>{};
  Failure? listFailure;
  Failure? detailFailure;

  @override
  Future<Result<List<HistoryEntry>>> listCompleted(HistoryFilter filter) async {
    if (listFailure != null) {
      return Result.failure(listFailure!);
    }
    return Result.success(List<HistoryEntry>.from(entries));
  }

  @override
  Future<Result<HistoryDetail>> getDetail(String sessionId) async {
    if (detailFailure != null) {
      return Result.failure(detailFailure!);
    }
    final detail = details[sessionId];
    if (detail == null) {
      return const Result.failure(Failure.notFound('La compra no existe.'));
    }
    return Result.success(detail);
  }
}
