import 'package:home_market_tracker/core/database/repository_guard.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/markets/data/datasources/market_local_data_source.dart';
import 'package:home_market_tracker/features/markets/data/models/market_model.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl(this._dataSource);

  final MarketLocalDataSource _dataSource;

  @override
  Future<Result<List<Market>>> listActive({String? query}) {
    return RepositoryGuard.run(() async {
      final models = await _dataSource.listActive(query: query);
      return models.map((model) => model.toEntity()).toList(growable: false);
    });
  }

  @override
  Future<Result<Market>> getById(String id) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.getById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Result<Market?>> findByNormalizedName(String nameNormalized) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.findByNormalizedName(nameNormalized);
      return model?.toEntity();
    });
  }

  @override
  Future<Result<Market>> insert(Market market) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.insert(MarketModel.fromEntity(market));
      return model.toEntity();
    });
  }

  @override
  Future<Result<Market>> update(Market market) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.update(MarketModel.fromEntity(market));
      return model.toEntity();
    });
  }
}
