import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';
import 'package:home_market_tracker/features/dashboard/domain/usecases/get_market_price_suggestions.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_state.dart';

class MarketSuggestionsCubit extends Cubit<MarketSuggestionsState> {
  MarketSuggestionsCubit(this._getSuggestions)
      : super(const MarketSuggestionsState());

  final GetMarketPriceSuggestions _getSuggestions;

  Future<void> started() => _load();

  Future<void> retried() => _load();

  Future<void> _load() async {
    emit(
      state.copyWith(
        status: MarketSuggestionsStatus.loading,
        clearFailure: true,
      ),
    );
    final result = await _getSuggestions(const NoParams());
    if (isClosed) return;
    switch (result) {
      case Success<List<MarketSuggestionGroup>>(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty
                ? MarketSuggestionsStatus.empty
                : MarketSuggestionsStatus.data,
            groups: value,
          ),
        );
      case FailureResult<List<MarketSuggestionGroup>>(:final failure):
        emit(
          state.copyWith(
            status: MarketSuggestionsStatus.error,
            failure: failure,
          ),
        );
    }
  }
}
