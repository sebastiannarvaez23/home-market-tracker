import 'package:equatable/equatable.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';

enum EfficiencyBand {
  high,
  medium,
  low;

  static EfficiencyBand fromValue(double value) {
    if (value >= 80) return EfficiencyBand.high;
    if (value >= 50) return EfficiencyBand.medium;
    return EfficiencyBand.low;
  }
}

class SpendVariation extends Equatable {
  const SpendVariation({
    required this.hasComparisonBase,
    required this.percent,
  });

  factory SpendVariation.noneNeeded() =>
      const SpendVariation(hasComparisonBase: true, percent: 0);

  factory SpendVariation.withoutBase() =>
      const SpendVariation(hasComparisonBase: false, percent: null);

  factory SpendVariation.percent(double value) =>
      SpendVariation(hasComparisonBase: true, percent: value);

  final bool hasComparisonBase;
  final double? percent;

  @override
  List<Object?> get props => [hasComparisonBase, percent];
}

class EfficiencyIndex extends Equatable {
  const EfficiencyIndex({required this.value, required this.band});

  final double value;
  final EfficiencyBand band;

  @override
  List<Object?> get props => [value, band];
}

class OverpriceAlert extends Equatable {
  const OverpriceAlert({
    required this.productName,
    required this.marketName,
    required this.paidPrice,
    required this.bestPrice,
    required this.difference,
  });

  final String productName;
  final String marketName;
  final Money paidPrice;
  final Money bestPrice;
  final Money difference;

  @override
  List<Object?> get props =>
      [productName, marketName, paidPrice, bestPrice, difference];
}

class MarketSpendSummary extends Equatable {
  const MarketSpendSummary({
    required this.marketId,
    required this.marketName,
    required this.total,
  });

  final String marketId;
  final String marketName;
  final Money total;

  @override
  List<Object?> get props => [marketId, marketName, total];
}

class ProductSpendSummary extends Equatable {
  const ProductSpendSummary({
    required this.productId,
    required this.productName,
    required this.total,
  });

  final String productId;
  final String productName;
  final Money total;

  @override
  List<Object?> get props => [productId, productName, total];
}

class MonthlySpend extends Equatable {
  const MonthlySpend({required this.monthStart, required this.total});

  final DateTime monthStart;
  final Money total;

  @override
  List<Object?> get props => [monthStart, total];
}

class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.window,
    required this.periodSpend,
    required this.previousPeriodSpend,
    required this.variation,
    required this.averageTicket,
    required this.purchaseCount,
    required this.efficiency,
    required this.potentialSavings,
    required this.overprices,
    required this.mostConvenientMarket,
    required this.highestSpendMarket,
    required this.topProducts,
    required this.trend,
  });

  final DashboardWindow window;
  final Money periodSpend;
  final Money previousPeriodSpend;
  final SpendVariation variation;
  final Money? averageTicket;
  final int purchaseCount;
  final EfficiencyIndex? efficiency;
  final Money potentialSavings;
  final List<OverpriceAlert> overprices;
  final MarketSpendSummary? mostConvenientMarket;
  final MarketSpendSummary? highestSpendMarket;
  final List<ProductSpendSummary> topProducts;
  final List<MonthlySpend> trend;

  @override
  List<Object?> get props => [
        window,
        periodSpend,
        previousPeriodSpend,
        variation,
        averageTicket,
        purchaseCount,
        efficiency,
        potentialSavings,
        overprices,
        mostConvenientMarket,
        highestSpendMarket,
        topProducts,
        trend,
      ];
}
