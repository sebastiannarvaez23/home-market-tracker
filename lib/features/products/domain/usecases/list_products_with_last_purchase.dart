import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/name_normalizer.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class ListProductsWithLastPurchaseParams {
  const ListProductsWithLastPurchaseParams({this.nameQuery});

  final String? nameQuery;
}

class ListProductsWithLastPurchase
    extends UseCase<List<ProductWithLastPurchase>, ListProductsWithLastPurchaseParams> {
  ListProductsWithLastPurchase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<ProductWithLastPurchase>>> call(
    ListProductsWithLastPurchaseParams params,
  ) {
    final query = params.nameQuery?.trim();
    final normalized =
        (query == null || query.isEmpty) ? null : NameNormalizer.normalize(query);
    return _repository.listActiveWithLastPurchase(nameQuery: normalized);
  }
}
