import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';

abstract class MarketRepository {
  Future<Result<List<Market>>> listActive({String? query});

  Future<Result<Market>> getById(String id);

  Future<Result<Market?>> findByNormalizedName(String nameNormalized);

  Future<Result<Market>> insert(Market market);

  Future<Result<Market>> update(Market market);
}
