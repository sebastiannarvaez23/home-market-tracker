import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/name_normalizer.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class ListShoppingCatalogParams {
  const ListShoppingCatalogParams({this.nameQuery});

  final String? nameQuery;
}

class ListShoppingCatalog
    extends UseCase<List<ShoppingProductRef>, ListShoppingCatalogParams> {
  ListShoppingCatalog(this._repository);

  final ShoppingRepository _repository;

  @override
  Future<Result<List<ShoppingProductRef>>> call(
    ListShoppingCatalogParams params,
  ) {
    final query = params.nameQuery?.trim();
    final normalized =
        (query == null || query.isEmpty) ? null : NameNormalizer.normalize(query);
    return _repository.listActiveProducts(nameQuery: normalized);
  }
}
