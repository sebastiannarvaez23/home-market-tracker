import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';

enum PickMarketStatus { initial, loading, empty, data, error }

class PickMarketState extends Equatable {
  const PickMarketState({
    this.status = PickMarketStatus.initial,
    this.markets = const [],
    this.failure,
    this.isCreating = false,
    this.createFailure,
    this.showCreateForm = false,
  });

  final PickMarketStatus status;
  final List<Market> markets;
  final Failure? failure;
  final bool isCreating;
  final Failure? createFailure;
  final bool showCreateForm;

  PickMarketState copyWith({
    PickMarketStatus? status,
    List<Market>? markets,
    Failure? failure,
    bool clearFailure = false,
    bool? isCreating,
    Failure? createFailure,
    bool clearCreateFailure = false,
    bool? showCreateForm,
  }) {
    return PickMarketState(
      status: status ?? this.status,
      markets: markets ?? this.markets,
      failure: clearFailure ? null : (failure ?? this.failure),
      isCreating: isCreating ?? this.isCreating,
      createFailure:
          clearCreateFailure ? null : (createFailure ?? this.createFailure),
      showCreateForm: showCreateForm ?? this.showCreateForm,
    );
  }

  @override
  List<Object?> get props => [
        status,
        markets,
        failure,
        isCreating,
        createFailure,
        showCreateForm,
      ];
}
