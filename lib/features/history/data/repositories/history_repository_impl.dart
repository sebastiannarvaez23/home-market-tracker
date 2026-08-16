import 'package:home_market_tracker/core/database/repository_guard.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/history/data/datasources/history_local_data_source.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._dataSource);

  final HistoryLocalDataSource _dataSource;

  @override
  Future<Result<List<HistoryEntry>>> listCompleted(HistoryFilter filter) {
    return RepositoryGuard.run(() async {
      final models = await _dataSource.listCompleted(filter);
      return models.map((model) => model.toEntity()).toList(growable: false);
    });
  }

  @override
  Future<Result<HistoryDetail>> getDetail(String sessionId) {
    return RepositoryGuard.run(() async {
      final model = await _dataSource.getDetail(sessionId);
      return model.toEntity();
    });
  }
}
