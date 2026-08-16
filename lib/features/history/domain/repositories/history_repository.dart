import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';

class HistoryFilter {
  const HistoryFilter({
    this.marketId,
    this.fromCompletedAtInclusive,
    this.toCompletedAtExclusive,
  });

  final String? marketId;
  final int? fromCompletedAtInclusive;
  final int? toCompletedAtExclusive;
}

abstract class HistoryRepository {
  Future<Result<List<HistoryEntry>>> listCompleted(HistoryFilter filter);

  Future<Result<HistoryDetail>> getDetail(String sessionId);
}
