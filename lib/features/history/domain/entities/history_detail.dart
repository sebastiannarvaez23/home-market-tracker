import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_line.dart';

class HistoryDetail extends Equatable {
  const HistoryDetail({
    required this.id,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.completedAt,
    required this.total,
    required this.lines,
  });

  final String id;
  final String marketId;
  final String marketNameSnapshot;
  final int completedAt;
  final Money total;
  final List<HistoryLine> lines;

  @override
  List<Object?> get props => [
        id,
        marketId,
        marketNameSnapshot,
        completedAt,
        total,
        lines,
      ];
}
