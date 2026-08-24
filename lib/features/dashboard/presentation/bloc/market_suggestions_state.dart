import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';

enum MarketSuggestionsStatus { initial, loading, empty, data, error }

class MarketSuggestionsState extends Equatable {
  const MarketSuggestionsState({
    this.status = MarketSuggestionsStatus.initial,
    this.groups = const [],
    this.failure,
  });

  final MarketSuggestionsStatus status;
  final List<MarketSuggestionGroup> groups;
  final Failure? failure;

  MarketSuggestionsState copyWith({
    MarketSuggestionsStatus? status,
    List<MarketSuggestionGroup>? groups,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return MarketSuggestionsState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, groups, failure];
}
