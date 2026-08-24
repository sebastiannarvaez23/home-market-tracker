import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';

class BestPriceOffer extends Equatable {
  const BestPriceOffer({
    required this.productId,
    required this.productName,
    required this.marketId,
    required this.marketName,
    required this.unitPrice,
    required this.uom,
    required this.purchasedAt,
  });

  final String productId;
  final String productName;
  final String marketId;
  final String marketName;
  final Money unitPrice;
  final UnitOfMeasure uom;
  final int purchasedAt;

  @override
  List<Object?> get props => [
        productId,
        productName,
        marketId,
        marketName,
        unitPrice,
        uom,
        purchasedAt,
      ];
}

class MarketSuggestedItem extends Equatable {
  const MarketSuggestedItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.uom,
  });

  final String productId;
  final String productName;
  final Money unitPrice;
  final UnitOfMeasure uom;

  @override
  List<Object?> get props => [productId, productName, unitPrice, uom];
}

class MarketSuggestionGroup extends Equatable {
  const MarketSuggestionGroup({
    required this.marketId,
    required this.marketName,
    required this.items,
  });

  final String marketId;
  final String marketName;
  final List<MarketSuggestedItem> items;

  @override
  List<Object?> get props => [marketId, marketName, items];
}
