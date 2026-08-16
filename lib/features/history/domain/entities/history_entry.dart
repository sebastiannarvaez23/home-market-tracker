import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.completedAt,
    required this.total,
    required this.itemCount,
  });

  final String id;
  final String marketId;
  final String marketNameSnapshot;
  final int completedAt;
  final Money total;
  final int itemCount;

  @override
  List<Object?> get props => [
        id,
        marketId,
        marketNameSnapshot,
        completedAt,
        total,
        itemCount,
      ];
}
