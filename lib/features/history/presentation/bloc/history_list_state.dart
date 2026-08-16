import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';

enum HistoryListStatus { initial, loading, empty, data, error }

class HistoryListState extends Equatable {
  const HistoryListState({
    this.status = HistoryListStatus.initial,
    this.entries = const [],
    this.failure,
  });

  final HistoryListStatus status;
  final List<HistoryEntry> entries;
  final Failure? failure;

  HistoryListState copyWith({
    HistoryListStatus? status,
    List<HistoryEntry>? entries,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return HistoryListState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, entries, failure];
}
