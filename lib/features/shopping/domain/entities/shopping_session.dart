import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session_status.dart';

class ShoppingSession extends Equatable {
  ShoppingSession({
    required this.id,
    required this.marketId,
    required this.marketNameSnapshot,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.items,
  }) : total = items.fold(Money.zero(), (sum, item) => sum + item.lineTotal);

  final String id;
  final String marketId;
  final String marketNameSnapshot;
  final ShoppingSessionStatus status;
  final int startedAt;
  final int? completedAt;
  final List<ShoppingItem> items;
  final Money total;

  bool get isInProgress => status == ShoppingSessionStatus.inProgress;

  ShoppingSession copyWith({
    ShoppingSessionStatus? status,
    int? completedAt,
    bool clearCompletedAt = false,
    List<ShoppingItem>? items,
  }) {
    return ShoppingSession(
      id: id,
      marketId: marketId,
      marketNameSnapshot: marketNameSnapshot,
      status: status ?? this.status,
      startedAt: startedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        marketId,
        marketNameSnapshot,
        status,
        startedAt,
        completedAt,
        items,
        total,
      ];
}
