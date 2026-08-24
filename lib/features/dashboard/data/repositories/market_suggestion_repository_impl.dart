import 'package:home_market_tracker/core/database/repository_guard.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/market_suggestion_repository.dart';

class MarketSuggestionRepositoryImpl implements MarketSuggestionRepository {
  MarketSuggestionRepositoryImpl(this._dataSource);

  final DashboardLocalDataSource _dataSource;

  @override
  Future<Result<List<BestPriceOffer>>> loadBestPriceOffers() {
    return RepositoryGuard.run(_dataSource.listBestPriceOffers);
  }
}
