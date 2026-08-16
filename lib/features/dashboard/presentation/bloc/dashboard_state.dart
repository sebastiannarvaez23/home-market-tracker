import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';

enum DashboardStatus { initial, loading, data, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.snapshot,
    this.failure,
  });

  final DashboardStatus status;
  final DashboardSnapshot? snapshot;
  final Failure? failure;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSnapshot? snapshot,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, snapshot, failure];
}
