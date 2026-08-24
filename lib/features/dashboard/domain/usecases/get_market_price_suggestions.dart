import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/market_suggestion_repository.dart';
import 'package:home_market_tracker/features/dashboard/domain/services/market_suggestion_assembler.dart';

class GetMarketPriceSuggestions
    extends UseCase<List<MarketSuggestionGroup>, NoParams> {
  GetMarketPriceSuggestions(this._repository);

  final MarketSuggestionRepository _repository;

  @override
  Future<Result<List<MarketSuggestionGroup>>> call(NoParams params) async {
    final result = await _repository.loadBestPriceOffers();
    return result.map(MarketSuggestionAssembler.group);
  }
}
