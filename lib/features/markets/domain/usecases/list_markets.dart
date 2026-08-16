import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/name_normalizer.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';

class ListMarketsParams {
  const ListMarketsParams({this.query});

  final String? query;
}

class ListMarkets extends UseCase<List<Market>, ListMarketsParams> {
  ListMarkets(this._repository);

  final MarketRepository _repository;

  @override
  Future<Result<List<Market>>> call(ListMarketsParams params) {
    final query = params.query?.trim();
    final normalized =
        (query == null || query.isEmpty) ? null : NameNormalizer.normalize(query);
    return _repository.listActive(query: normalized);
  }
}
