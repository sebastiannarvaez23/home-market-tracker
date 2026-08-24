import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';

abstract final class MarketSuggestionAssembler {
  static List<BestPriceOffer> pickOnePerProduct(List<BestPriceOffer> offers) {
    final byProduct = <String, BestPriceOffer>{};
    for (final offer in offers) {
      final current = byProduct[offer.productId];
      if (current == null ||
          offer.purchasedAt > current.purchasedAt ||
          (offer.purchasedAt == current.purchasedAt &&
              offer.marketName.toLowerCase().compareTo(
                    current.marketName.toLowerCase(),
                  ) <
                  0)) {
        byProduct[offer.productId] = offer;
      }
    }
    return byProduct.values.toList(growable: false);
  }

  static List<MarketSuggestionGroup> group(List<BestPriceOffer> offers) {
    final unique = pickOnePerProduct(offers);
    final itemsByMarket = <String, List<MarketSuggestedItem>>{};
    final names = <String, String>{};
    for (final offer in unique) {
      names[offer.marketId] = offer.marketName;
      itemsByMarket.putIfAbsent(offer.marketId, () => []).add(
            MarketSuggestedItem(
              productId: offer.productId,
              productName: offer.productName,
              unitPrice: offer.unitPrice,
              uom: offer.uom,
            ),
          );
    }
    final groups = [
      for (final marketId in itemsByMarket.keys)
        MarketSuggestionGroup(
          marketId: marketId,
          marketName: names[marketId]!,
          items: (itemsByMarket[marketId]!
                ..sort(
                  (a, b) => a.productName.toLowerCase().compareTo(
                        b.productName.toLowerCase(),
                      ),
                ))
              .toList(growable: false),
        ),
    ]..sort(
        (a, b) => a.marketName.toLowerCase().compareTo(b.marketName.toLowerCase()),
      );
    return groups;
  }
}
