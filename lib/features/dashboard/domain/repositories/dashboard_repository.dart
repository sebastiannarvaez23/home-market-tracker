import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';

abstract class DashboardRepository {
  Future<Result<DashboardFacts>> loadFacts(DashboardWindow window);
}
