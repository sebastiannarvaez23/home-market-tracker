import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getSnapshot) : super(const DashboardState());

  final GetDashboardSnapshot _getSnapshot;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  Future<void> refreshed() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(
          status: DashboardStatus.loading,
          clearFailure: true,
        ),
      );
    }
    final result = await _getSnapshot(const GetDashboardSnapshotParams());
    if (isClosed) return;
    switch (result) {
      case Success<DashboardSnapshot>(:final value):
        emit(
          state.copyWith(
            status: DashboardStatus.data,
            snapshot: value,
          ),
        );
      case FailureResult<DashboardSnapshot>(:final failure):
        emit(
          state.copyWith(
            status: DashboardStatus.error,
            failure: failure,
          ),
        );
    }
  }
}
