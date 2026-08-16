import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/domain/usecases/list_completed_shoppings.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_state.dart';

class HistoryListCubit extends Cubit<HistoryListState> {
  HistoryListCubit(this._listCompleted) : super(const HistoryListState());

  final ListCompletedShoppings _listCompleted;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  Future<void> refreshed() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(
          status: HistoryListStatus.loading,
          clearFailure: true,
        ),
      );
    }
    final result = await _listCompleted(const ListCompletedShoppingsParams());
    if (isClosed) return;
    switch (result) {
      case Success<List<HistoryEntry>>(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty
                ? HistoryListStatus.empty
                : HistoryListStatus.data,
            entries: value,
          ),
        );
      case FailureResult<List<HistoryEntry>>(:final failure):
        emit(
          state.copyWith(
            status: HistoryListStatus.error,
            failure: failure,
          ),
        );
    }
  }
}
