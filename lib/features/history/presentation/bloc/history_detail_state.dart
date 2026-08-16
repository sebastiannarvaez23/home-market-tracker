import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';

enum HistoryDetailStatus { initial, loading, data, error }

class HistoryDetailState extends Equatable {
  const HistoryDetailState({
    this.status = HistoryDetailStatus.initial,
    this.detail,
    this.failure,
  });

  final HistoryDetailStatus status;
  final HistoryDetail? detail;
  final Failure? failure;

  HistoryDetailState copyWith({
    HistoryDetailStatus? status,
    HistoryDetail? detail,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return HistoryDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, detail, failure];
}
