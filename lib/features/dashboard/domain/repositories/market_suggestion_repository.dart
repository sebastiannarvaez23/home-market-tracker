import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';

abstract class MarketSuggestionRepository {
  Future<Result<List<BestPriceOffer>>> loadBestPriceOffers();
}
