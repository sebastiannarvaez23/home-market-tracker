import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> listActive({String? nameQuery});

  Future<Result<List<ProductWithLastPurchase>>> listActiveWithLastPurchase({
    String? nameQuery,
  });

  Future<Result<Product>> getById(String id);

  Future<Result<Product?>> findByNormalizedName(String nameNormalized);

  Future<Result<Product>> insert(Product product);

  Future<Result<Product>> update(Product product);

  Future<Result<List<ProductPurchaseHistoryEntry>>> listPurchaseHistory(
    String productId,
  );
}
