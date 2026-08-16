import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';
import 'package:home_market_tracker/features/dashboard/domain/services/dashboard_calculator.dart';

void main() {
  const calculator = DashboardCalculator();
  final window = DashboardWindow.fromAnchor(DateTime(2026, 8, 15));

  ItemSpendFact item({
    required String productId,
    required String marketId,
    required int unitCents,
    required int lineCents,
    String productName = 'Arroz',
    String marketName = 'Éxito',
  }) {
    return ItemSpendFact(
      productId: productId,
      productName: productName,
      marketId: marketId,
      marketName: marketName,
      quantity: Quantity.one(),
      uom: UnitOfMeasure.unit,
      unitPrice: Money.cents(unitCents),
      lineTotal: Money.cents(lineCents),
    );
  }

  test('gasto, ticket y variación vs mes anterior', () {
    final snapshot = calculator.calculate(
      DashboardFacts(
        window: window,
        sessionsInPeriod: [
          SessionSpendFact(
            marketId: 'm1',
            marketName: 'Éxito',
            completedAt: DateTime(2026, 8, 2).millisecondsSinceEpoch,
            total: const Money.cents(10000),
          ),
          SessionSpendFact(
            marketId: 'm1',
            marketName: 'Éxito',
            completedAt: DateTime(2026, 8, 10).millisecondsSinceEpoch,
            total: const Money.cents(5000),
          ),
        ],
        sessionsInPrevious: [
          SessionSpendFact(
            marketId: 'm1',
            marketName: 'Éxito',
            completedAt: DateTime(2026, 7, 2).millisecondsSinceEpoch,
            total: const Money.cents(10000),
          ),
        ],
        itemsInPeriod: const [],
        minUnitPriceByProductId: const {},
        completedItemCountByProductId: const {},
        trendSessions: const [],
      ),
    );

    expect(snapshot.periodSpend.cents, 15000);
    expect(snapshot.purchaseCount, 2);
    expect(snapshot.averageTicket?.cents, 7500);
    expect(snapshot.variation.percent, 50);
    expect(snapshot.efficiency, isNull);
  });

  test('sin base de comparación si el mes anterior fue 0', () {
    final snapshot = calculator.calculate(
      DashboardFacts(
        window: window,
        sessionsInPeriod: [
          SessionSpendFact(
            marketId: 'm1',
            marketName: 'Éxito',
            completedAt: DateTime(2026, 8, 2).millisecondsSinceEpoch,
            total: const Money.cents(1000),
          ),
        ],
        sessionsInPrevious: const [],
        itemsInPeriod: const [],
        minUnitPriceByProductId: const {},
        completedItemCountByProductId: const {},
        trendSessions: const [],
      ),
    );
    expect(snapshot.variation.hasComparisonBase, isFalse);
  });

  test('índice 100 si se pagó el mejor precio conocido', () {
    final snapshot = calculator.calculate(
      DashboardFacts(
        window: window,
        sessionsInPeriod: const [],
        sessionsInPrevious: const [],
        itemsInPeriod: [
          item(productId: 'p1', marketId: 'm1', unitCents: 1000, lineCents: 1000),
        ],
        minUnitPriceByProductId: {'p1': const Money.cents(1000)},
        completedItemCountByProductId: const {'p1': 2},
        trendSessions: const [],
      ),
    );
    expect(snapshot.efficiency?.value, 100);
    expect(snapshot.efficiency?.band, EfficiencyBand.high);
    expect(snapshot.potentialSavings.cents, 0);
    expect(snapshot.overprices, isEmpty);
  });

  test('calcula exceso, sobreprecios y no elige mercado de primera compra', () {
    final snapshot = calculator.calculate(
      DashboardFacts(
        window: window,
        sessionsInPeriod: [
          SessionSpendFact(
            marketId: 'm1',
            marketName: 'Éxito',
            completedAt: DateTime(2026, 8, 2).millisecondsSinceEpoch,
            total: const Money.cents(2000),
          ),
        ],
        sessionsInPrevious: const [],
        itemsInPeriod: [
          item(productId: 'p1', marketId: 'm1', unitCents: 2000, lineCents: 2000),
        ],
        minUnitPriceByProductId: {'p1': const Money.cents(1000)},
        completedItemCountByProductId: const {'p1': 1},
        trendSessions: const [],
      ),
    );

    expect(snapshot.efficiency?.value, 50);
    expect(snapshot.potentialSavings.cents, 1000);
    expect(snapshot.overprices, hasLength(1));
    expect(snapshot.mostConvenientMarket, isNull);
    expect(snapshot.highestSpendMarket?.marketId, 'm1');
    expect(snapshot.topProducts.first.productId, 'p1');
  });

  test('serie de tendencia cubre 6 meses', () {
    final snapshot = calculator.calculate(
      DashboardFacts(
        window: window,
        sessionsInPeriod: const [],
        sessionsInPrevious: const [],
        itemsInPeriod: const [],
        minUnitPriceByProductId: const {},
        completedItemCountByProductId: const {},
        trendSessions: [
          SessionSpendFact(
            marketId: 'm1',
            marketName: 'Éxito',
            completedAt: DateTime(2026, 8, 5).millisecondsSinceEpoch,
            total: const Money.cents(3000),
          ),
        ],
      ),
    );
    expect(snapshot.trend, hasLength(6));
    expect(snapshot.trend.last.monthStart, DateTime(2026, 8, 1));
    expect(snapshot.trend.last.total.cents, 3000);
  });
}
