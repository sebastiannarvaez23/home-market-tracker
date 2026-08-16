import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:home_market_tracker/features/dashboard/domain/services/dashboard_calculator.dart';

class GetDashboardSnapshotParams {
  const GetDashboardSnapshotParams({this.anchor});

  final DateTime? anchor;
}

class GetDashboardSnapshot
    extends UseCase<DashboardSnapshot, GetDashboardSnapshotParams> {
  GetDashboardSnapshot(
    this._repository, {
    required Clock clock,
    DashboardCalculator calculator = const DashboardCalculator(),
  })  : _clock = clock,
        _calculator = calculator;

  final DashboardRepository _repository;
  final Clock _clock;
  final DashboardCalculator _calculator;

  @override
  Future<Result<DashboardSnapshot>> call(GetDashboardSnapshotParams params) async {
    final window = DashboardWindow.fromAnchor(params.anchor ?? _clock.now());
    final factsResult = await _repository.loadFacts(window);
    return factsResult.map(_calculator.calculate);
  }
}
