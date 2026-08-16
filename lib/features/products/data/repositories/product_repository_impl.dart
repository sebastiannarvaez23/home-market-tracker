import 'package:home_market_tracker/core/database/repository_guard.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/products/data/datasources/product_local_data_source.dart';
import 'package:home_market_tracker/features/products/data/models/product_model.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource);

  final ProductLocalDataSource _dataSource;

  @override
  Future<Result<List<Product>>> listActive({String? nameQuery}) {
    return RepositoryGuard.run(() async {
      final models = await _dataSource.listActive(nameQuery: nameQuery);
      return models.map((model) => model.toEntity()).toList(growable: false);
    });
  }

  @override
  Future<Result<List<ProductWithLastPurchase>>> listActiveWithLastPurchase({
    String? nameQuery,
  }) {
    return RepositoryGuard.run(() async {
      final models =
          await _dataSource.listActiveWithLastPurchase(nameQuery: nameQuery);
      return models
          .map((model) => model.toEntityWithLastPurchase())
          .toList(growable: false);
    });
  }

  @override
  Future<Result<Product>> getById(String id) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.getById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Result<Product?>> findByNormalizedName(String nameNormalized) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.findByNormalizedName(nameNormalized);
      return model?.toEntity();
    });
  }

  @override
  Future<Result<Product>> insert(Product product) {
    return RepositoryGuard.run(() async {
      final model =
          await _dataSource.insert(ProductModel.fromEntity(product));
      return model.toEntity();
    });
  }

  @override
  Future<Result<Product>> update(Product product) {
    return RepositoryGuard.run(() async {
      final model =
          await _dataSource.update(ProductModel.fromEntity(product));
      return model.toEntity();
    });
  }

  @override
  Future<Result<List<ProductPurchaseHistoryEntry>>> listPurchaseHistory(
    String productId,
  ) {
    return RepositoryGuard.run(() async {
      final models = await _dataSource.listPurchaseHistory(productId);
      return models.map((model) => model.toEntity()).toList(growable: false);
    });
  }
}
