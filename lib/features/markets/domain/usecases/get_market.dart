import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';

class GetMarket extends UseCase<Market, String> {
  GetMarket(this._repository);

  final MarketRepository _repository;

  @override
  Future<Result<Market>> call(String params) {
    return _repository.getById(params);
  }
}
