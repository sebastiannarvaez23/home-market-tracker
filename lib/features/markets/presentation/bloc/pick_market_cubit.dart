import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/create_market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/list_markets.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_state.dart';

class PickMarketCubit extends Cubit<PickMarketState> {
  PickMarketCubit(this._listMarkets, this._createMarket)
      : super(const PickMarketState());

  final ListMarkets _listMarkets;
  final CreateMarket _createMarket;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  void createFormOpened() {
    emit(
      state.copyWith(
        showCreateForm: true,
        clearCreateFailure: true,
        isCreating: false,
      ),
    );
  }

  Future<Market?> createMarket({required String name}) async {
    emit(state.copyWith(isCreating: true, clearCreateFailure: true));
    final result = await _createMarket(CreateMarketParams(name: name));
    if (isClosed) return null;

    switch (result) {
      case FailureResult<Market>(:final failure):
        emit(state.copyWith(isCreating: false, createFailure: failure));
        return null;
      case Success<Market>(:final value):
        emit(state.copyWith(isCreating: false, clearCreateFailure: true));
        return value;
    }
  }

  Future<void> _load() async {
    emit(state.copyWith(status: PickMarketStatus.loading, clearFailure: true));
    final result = await _listMarkets(const ListMarketsParams());
    if (isClosed) return;

    switch (result) {
      case Success<List<Market>>(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty ? PickMarketStatus.empty : PickMarketStatus.data,
            markets: value,
            showCreateForm: value.isEmpty,
          ),
        );
      case FailureResult<List<Market>>(:final failure):
        emit(
          state.copyWith(
            status: PickMarketStatus.error,
            failure: failure,
          ),
        );
    }
  }
}
