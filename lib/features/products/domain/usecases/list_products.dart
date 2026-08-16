import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/name_normalizer.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class ListProductsParams {
  const ListProductsParams({this.nameQuery});

  final String? nameQuery;
}

class ListProducts extends UseCase<List<Product>, ListProductsParams> {
  ListProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call(ListProductsParams params) {
    final query = params.nameQuery?.trim();
    final normalized =
        (query == null || query.isEmpty) ? null : NameNormalizer.normalize(query);
    return _repository.listActive(nameQuery: normalized);
  }
}
