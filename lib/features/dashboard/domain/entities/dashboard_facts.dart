import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';

class SessionSpendFact extends Equatable {
  const SessionSpendFact({
    required this.marketId,
    required this.marketName,
    required this.completedAt,
    required this.total,
  });

  final String marketId;
  final String marketName;
  final int completedAt;
  final Money total;

  @override
  List<Object?> get props => [marketId, marketName, completedAt, total];
}

class ItemSpendFact extends Equatable {
  const ItemSpendFact({
    required this.productId,
    required this.productName,
    required this.marketId,
    required this.marketName,
    required this.quantity,
    required this.uom,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String productId;
  final String productName;
  final String marketId;
  final String marketName;
  final Quantity quantity;
  final UnitOfMeasure uom;
  final Money unitPrice;
  final Money lineTotal;

  @override
  List<Object?> get props => [
        productId,
        productName,
        marketId,
        marketName,
        quantity,
        uom,
        unitPrice,
        lineTotal,
      ];
}

class DashboardFacts extends Equatable {
  const DashboardFacts({
    required this.window,
    required this.sessionsInPeriod,
    required this.sessionsInPrevious,
    required this.itemsInPeriod,
    required this.minUnitPriceByProductId,
    required this.completedItemCountByProductId,
    required this.trendSessions,
  });

  final DashboardWindow window;
  final List<SessionSpendFact> sessionsInPeriod;
  final List<SessionSpendFact> sessionsInPrevious;
  final List<ItemSpendFact> itemsInPeriod;
  final Map<String, Money> minUnitPriceByProductId;
  final Map<String, int> completedItemCountByProductId;
  final List<SessionSpendFact> trendSessions;

  @override
  List<Object?> get props => [
        window,
        sessionsInPeriod,
        sessionsInPrevious,
        itemsInPeriod,
        minUnitPriceByProductId,
        completedItemCountByProductId,
        trendSessions,
      ];
}
