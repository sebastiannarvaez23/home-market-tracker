import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_facts.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_window.dart';
import 'package:home_market_tracker/features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryDashboardRepository repository;
  late DashboardCubit cubit;
  final window = DashboardWindow.fromAnchor(DateTime(2026, 8, 15));

  setUp(() {
    repository = InMemoryDashboardRepository();
    cubit = DashboardCubit(
      GetDashboardSnapshot(
        repository,
        clock: FakeClock(DateTime(2026, 8, 15)),
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<DashboardCubit, DashboardState>(
    'carga el snapshot del mes actual',
    build: () {
      repository.result = Result.success(
        DashboardFacts(
          window: window,
          sessionsInPeriod: [
            SessionSpendFact(
              marketId: 'm1',
              marketName: 'Éxito',
              completedAt: DateTime(2026, 8, 2).millisecondsSinceEpoch,
              total: const Money.cents(15000),
            ),
          ],
          sessionsInPrevious: const [],
          itemsInPeriod: const [],
          minUnitPriceByProductId: const {},
          completedItemCountByProductId: const {},
          trendSessions: const [],
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.loading),
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.data)
          .having((s) => s.snapshot?.purchaseCount, 'purchases', 1)
          .having((s) => s.snapshot?.periodSpend.cents, 'spend', 15000),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'emite error cuando falla el repositorio',
    build: () {
      repository.result = const Result.failure(
        Failure.storage('No se pudo leer el dashboard.'),
      );
      return cubit;
    },
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.loading),
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.error),
    ],
  );
}
