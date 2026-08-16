import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/usecases/get_shopping_detail.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_state.dart';

class HistoryDetailCubit extends Cubit<HistoryDetailState> {
  HistoryDetailCubit(this._sessionId, this._getDetail)
      : super(const HistoryDetailState());

  final String _sessionId;
  final GetShoppingDetail _getDetail;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  Future<void> _load() async {
    emit(
      state.copyWith(
        status: HistoryDetailStatus.loading,
        clearFailure: true,
      ),
    );
    final result = await _getDetail(_sessionId);
    if (isClosed) return;
    switch (result) {
      case Success<HistoryDetail>(:final value):
        emit(
          state.copyWith(
            status: HistoryDetailStatus.data,
            detail: value,
          ),
        );
      case FailureResult<HistoryDetail>(:final failure):
        emit(
          state.copyWith(
            status: HistoryDetailStatus.error,
            failure: failure,
          ),
        );
    }
  }
}
