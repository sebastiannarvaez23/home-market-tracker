import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardCalculator {
  const DashboardCalculator();

  static const int overpriceLimit = 10;
  static const int topProductsLimit = 5;

  DashboardSnapshot calculate(DashboardFacts facts) {
    final periodSpend = _sumSessions(facts.sessionsInPeriod);
    final previousSpend = _sumSessions(facts.sessionsInPrevious);
    final purchaseCount = facts.sessionsInPeriod.length;
    final variation = _variation(periodSpend, previousSpend);
    final averageTicket = purchaseCount == 0
        ? null
        : Money.cents((periodSpend.cents / purchaseCount).round());

    final efficiencyResult = _efficiency(facts);
    final mostConvenient = _mostConvenientMarket(facts);
    final highestSpend = _highestSpendMarket(facts.sessionsInPeriod);
    final topProducts = _topProducts(facts.itemsInPeriod);
    final trend = _trend(facts);

    return DashboardSnapshot(
      window: facts.window,
      periodSpend: periodSpend,
      previousPeriodSpend: previousSpend,
      variation: variation,
      averageTicket: averageTicket,
      purchaseCount: purchaseCount,
      efficiency: efficiencyResult.index,
      potentialSavings: efficiencyResult.savings,
      overprices: efficiencyResult.overprices,
      mostConvenientMarket: mostConvenient,
      highestSpendMarket: highestSpend,
      topProducts: topProducts,
      trend: trend,
    );
  }

  Money _sumSessions(List<SessionSpendFact> sessions) {
    return sessions.fold(Money.zero(), (sum, session) => sum + session.total);
  }

  SpendVariation _variation(Money current, Money previous) {
    if (previous.cents == 0 && current.cents == 0) {
      return SpendVariation.noneNeeded();
    }
    if (previous.cents == 0) {
      return SpendVariation.withoutBase();
    }
    final percent = ((current.cents - previous.cents) / previous.cents) * 100;
    return SpendVariation.percent(percent);
  }

  _EfficiencyResult _efficiency(DashboardFacts facts) {
    if (facts.itemsInPeriod.isEmpty) {
      return const _EfficiencyResult(
        index: null,
        savings: Money.cents(0),
        overprices: [],
      );
    }

    var excessCents = 0;
    var spendCents = 0;
    final overprices = <OverpriceAlert>[];

    for (final item in facts.itemsInPeriod) {
      spendCents += item.lineTotal.cents;
      final reference =
          facts.minUnitPriceByProductId[item.productId] ?? item.unitPrice;
      if (item.unitPrice > reference) {
        final difference = item.unitPrice.minusClamped(reference).times(item.quantity);
        excessCents += difference.cents;
        overprices.add(
          OverpriceAlert(
            productName: item.productName,
            marketName: item.marketName,
            paidPrice: item.unitPrice,
            bestPrice: reference,
            difference: difference,
          ),
        );
      }
    }

    overprices.sort((a, b) => b.difference.compareTo(a.difference));
    final limited = overprices.take(overpriceLimit).toList(growable: false);

    if (spendCents == 0) {
      return _EfficiencyResult(
        index: null,
        savings: Money.cents(excessCents),
        overprices: limited,
      );
    }

    final raw = 100 * (1 - (excessCents / spendCents));
    final clamped = raw < 0 ? 0.0 : (raw > 100 ? 100.0 : raw);
    return _EfficiencyResult(
      index: EfficiencyIndex(
        value: clamped,
        band: EfficiencyBand.fromValue(clamped),
      ),
      savings: Money.cents(excessCents),
      overprices: limited,
    );
  }

  MarketSpendSummary? _mostConvenientMarket(DashboardFacts facts) {
    final grouped = <String, List<ItemSpendFact>>{};
    for (final item in facts.itemsInPeriod) {
      grouped.putIfAbsent(item.marketId, () => []).add(item);
    }

    MarketSpendSummary? best;
    double? bestEfficiency;

    grouped.forEach((marketId, items) {
      final eligible = items.any((item) {
        final count = facts.completedItemCountByProductId[item.productId] ?? 0;
        return count > 1;
      });
      if (!eligible) {
        return;
      }

      var excessCents = 0;
      var spendCents = 0;
      for (final item in items) {
        spendCents += item.lineTotal.cents;
        final reference =
            facts.minUnitPriceByProductId[item.productId] ?? item.unitPrice;
        if (item.unitPrice > reference) {
          excessCents +=
              item.unitPrice.minusClamped(reference).times(item.quantity).cents;
        }
      }
      if (spendCents == 0) {
        return;
      }
      final efficiency = 100 * (1 - (excessCents / spendCents));
      final total = items.fold(Money.zero(), (sum, item) => sum + item.lineTotal);
      final candidate = MarketSpendSummary(
        marketId: marketId,
        marketName: items.first.marketName,
        total: total,
      );
      if (best == null ||
          efficiency > bestEfficiency! ||
          (efficiency == bestEfficiency && total < best!.total)) {
        best = candidate;
        bestEfficiency = efficiency;
      }
    });

    return best;
  }

  MarketSpendSummary? _highestSpendMarket(List<SessionSpendFact> sessions) {
    if (sessions.isEmpty) return null;
    final totals = <String, MarketSpendSummary>{};
    for (final session in sessions) {
      final current = totals[session.marketId];
      final total = (current?.total ?? Money.zero()) + session.total;
      totals[session.marketId] = MarketSpendSummary(
        marketId: session.marketId,
        marketName: session.marketName,
        total: total,
      );
    }
    final ranked = totals.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return ranked.first;
  }

  List<ProductSpendSummary> _topProducts(List<ItemSpendFact> items) {
    final totals = <String, ProductSpendSummary>{};
    for (final item in items) {
      final current = totals[item.productId];
      totals[item.productId] = ProductSpendSummary(
        productId: item.productId,
        productName: item.productName,
        total: (current?.total ?? Money.zero()) + item.lineTotal,
      );
    }
    final ranked = totals.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return ranked.take(topProductsLimit).toList(growable: false);
  }

  List<MonthlySpend> _trend(DashboardFacts facts) {
    final months = <DateTime>[];
    var cursor = facts.window.trendStart;
    while (cursor.isBefore(facts.window.periodEndExclusive)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    return months.map((monthStart) {
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
      final startMs = monthStart.millisecondsSinceEpoch;
      final endMs = monthEnd.millisecondsSinceEpoch;
      final total = facts.trendSessions.fold(Money.zero(), (sum, session) {
        if (session.completedAt >= startMs && session.completedAt < endMs) {
          return sum + session.total;
        }
        return sum;
      });
      return MonthlySpend(monthStart: monthStart, total: total);
    }).toList(growable: false);
  }
}

class _EfficiencyResult {
  const _EfficiencyResult({
    required this.index,
    required this.savings,
    required this.overprices,
  });

  final EfficiencyIndex? index;
  final Money savings;
  final List<OverpriceAlert> overprices;
}
