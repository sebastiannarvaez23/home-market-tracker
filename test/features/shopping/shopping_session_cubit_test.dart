import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/cancel_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/complete_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/get_in_progress_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/list_shopping_catalog.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/start_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/upsert_shopping_item.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_cubit.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryShoppingRepository repository;
  late FakeClock clock;
  late ShoppingSessionCubit cubit;

  ShoppingSessionCubit buildCubit() {
    return ShoppingSessionCubit(
      getInProgress: GetInProgressShopping(repository),
      listCatalog: ListShoppingCatalog(repository),
      upsertItem: UpsertShoppingItem(
        repository,
        idGenerator: SequentialIdGenerator(['i1', 'i2']),
      ),
      completeShopping: CompleteShopping(repository, clock: clock),
      cancelShopping: CancelShopping(repository),
    );
  }

  setUp(() async {
    repository = InMemoryShoppingRepository()
      ..markets['m1'] = const ShoppingMarketRef(
        id: 'm1',
        name: 'Éxito',
        isActive: true,
      )
      ..catalogProducts['p1'] = const ShoppingProductRef(
        id: 'p1',
        name: 'Arroz',
        isActive: true,
      )
      ..catalogProducts['p2'] = const ShoppingProductRef(
        id: 'p2',
        name: 'Leche',
        isActive: true,
      );
    clock = FakeClock(DateTime(2026, 8, 15, 12));
    await StartShopping(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(['s1']),
    )(const StartShoppingParams(marketId: 'm1'));
    cubit = buildCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<ShoppingSessionCubit, ShoppingSessionState>(
    'carga la sesión y el catálogo',
    build: () => cubit,
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<ShoppingSessionState>()
          .having((s) => s.status, 'status', ShoppingViewStatus.loading),
      isA<ShoppingSessionState>()
          .having((s) => s.status, 'status', ShoppingViewStatus.data)
          .having((s) => s.session?.marketNameSnapshot, 'market', 'Éxito')
          .having((s) => s.products.map((p) => p.id), 'products', ['p1', 'p2']),
    ],
  );

  blocTest<ShoppingSessionCubit, ShoppingSessionState>(
    'al agregar un producto actualiza el total',
    build: () => cubit,
    act: (cubit) async {
      await cubit.started();
      await cubit.addItem(productId: 'p1', unitPrice: r'$ 3.200', quantity: '2');
    },
    verify: (cubit) {
      expect(cubit.state.total, const Money.cents(640000));
      expect(cubit.state.itemFor('p1')?.productId, 'p1');
    },
  );

  blocTest<ShoppingSessionCubit, ShoppingSessionState>(
    'filtra el catálogo por nombre',
    build: () => cubit,
    act: (cubit) async {
      await cubit.started();
      await cubit.queryChanged('lec');
    },
    verify: (cubit) {
      expect(cubit.state.products.single.id, 'p2');
      expect(cubit.state.query, 'lec');
    },
  );
}
