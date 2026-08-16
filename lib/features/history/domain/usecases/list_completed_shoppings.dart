import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';
import 'package:home_market_tracker/features/history/domain/repositories/history_repository.dart';

class ListCompletedShoppingsParams {
  const ListCompletedShoppingsParams({
    this.marketId,
    this.fromCompletedAtInclusive,
    this.toCompletedAtExclusive,
  });

  final String? marketId;
  final int? fromCompletedAtInclusive;
  final int? toCompletedAtExclusive;
}

class ListCompletedShoppings
    extends UseCase<List<HistoryEntry>, ListCompletedShoppingsParams> {
  ListCompletedShoppings(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Result<List<HistoryEntry>>> call(ListCompletedShoppingsParams params) {
    return _repository.listCompleted(
      HistoryFilter(
        marketId: params.marketId,
        fromCompletedAtInclusive: params.fromCompletedAtInclusive,
        toCompletedAtExclusive: params.toCompletedAtExclusive,
      ),
    );
  }
}
