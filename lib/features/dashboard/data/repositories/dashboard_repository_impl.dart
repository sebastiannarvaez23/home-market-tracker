import 'package:home_market_tracker/core/database/repository_guard.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dataSource);

  final DashboardLocalDataSource _dataSource;

  @override
  Future<Result<DashboardFacts>> loadFacts(DashboardWindow window) {
    return RepositoryGuard.run(() => _dataSource.loadFacts(window));
  }
}
