import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/create_market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/list_markets.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_cubit.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryMarketRepository repository;
  late PickMarketCubit cubit;

  Market market(String id, String name) {
    return Market(
      id: id,
      name: name,
      nameNormalized: name.toLowerCase(),
      location: null,
      notes: null,
      isActive: true,
      createdAt: 1,
      updatedAt: 1,
    );
  }

  PickMarketCubit buildCubit({List<String> ids = const ['m-new']}) {
    return PickMarketCubit(
      ListMarkets(repository),
      CreateMarket(
        repository,
        clock: FakeClock(DateTime(2026, 8, 15)),
        idGenerator: SequentialIdGenerator(ids),
      ),
    );
  }

  setUp(() {
    repository = InMemoryMarketRepository();
    cubit = buildCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<PickMarketCubit, PickMarketState>(
    'emite empty cuando no hay mercados',
    build: () => cubit,
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<PickMarketState>()
          .having((s) => s.status, 'status', PickMarketStatus.loading),
      isA<PickMarketState>()
          .having((s) => s.status, 'status', PickMarketStatus.empty)
          .having((s) => s.showCreateForm, 'create', true),
    ],
  );

  blocTest<PickMarketCubit, PickMarketState>(
    'lista mercados activos',
    build: () {
      repository.markets['m1'] = market('m1', 'Éxito');
      return cubit;
    },
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<PickMarketState>()
          .having((s) => s.status, 'status', PickMarketStatus.loading),
      isA<PickMarketState>()
          .having((s) => s.status, 'status', PickMarketStatus.data)
          .having((s) => s.markets.single.name, 'name', 'Éxito'),
    ],
  );

  test('crea un mercado y lo devuelve', () async {
    final created = await cubit.createMarket(name: 'Olímpica');
    expect(created?.name, 'Olímpica');
    expect(repository.markets['m-new']?.name, 'Olímpica');
  });
}
