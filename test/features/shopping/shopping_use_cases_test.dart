import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/complete_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/list_shopping_catalog.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/start_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/upsert_shopping_item.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryShoppingRepository repository;
  late FakeClock clock;

  setUp(() {
    repository = InMemoryShoppingRepository()
      ..markets['m1'] = const ShoppingMarketRef(
        id: 'm1',
        name: 'Éxito',
        isActive: true,
      )
      ..markets['m-inactive'] = const ShoppingMarketRef(
        id: 'm-inactive',
        name: 'Cerrado',
        isActive: false,
      )
      ..catalogProducts['prod1'] = const ShoppingProductRef(
        id: 'prod1',
        name: 'Arroz',
        isActive: true,
        uomLadder: UomLadder(
          base: UnitOfMeasure.unit,
          steps: [
            UomLadderStep(
              uom: UnitOfMeasure.pack,
              factor: Quantity.milli(2000),
            ),
          ],
        ),
      );
    clock = FakeClock(DateTime(2026, 8, 14, 12));
  });

  test('no inicia compra si el mercado está inactivo', () async {
    final result = await StartShopping(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(['s1']),
    )(const StartShoppingParams(marketId: 'm-inactive'));
    expect(result.failureOrNull?.code, FailureCode.inactive);
  });

  test('conflicto si ya hay una compra en curso', () async {
    final start = StartShopping(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(['s1', 's2']),
    );
    await start(const StartShoppingParams(marketId: 'm1'));
    final second = await start(const StartShoppingParams(marketId: 'm1'));
    expect(second.failureOrNull?.code, FailureCode.conflict);
  });

  test('no agrega ítems sin sesión en curso', () async {
    final result = await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(const UpsertShoppingItemParams(productId: 'prod1', unitPrice: 3200));
    expect(result.failureOrNull?.code, FailureCode.precondition);
  });

  test('recalcula el total al agregar productos y no completa vacío', () async {
    await StartShopping(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(['s1']),
    )(const StartShoppingParams(marketId: 'm1'));

    final emptyComplete = await CompleteShopping(repository, clock: clock)(
      const NoParams(),
    );
    expect(emptyComplete.failureOrNull?.code, FailureCode.precondition);

    final session = await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(
      const UpsertShoppingItemParams(
        productId: 'prod1',
        unitPrice: 10.5,
        quantity: 2,
      ),
    );
    final value = (session as Success<ShoppingSession>).value;
    expect(value.total, const Money.cents(2100));
    expect(value.items.single.uom, UnitOfMeasure.unit);
    expect(value.items.single.uomFactor, Quantity.one());

    final withPack = await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(
      const UpsertShoppingItemParams(
        productId: 'prod1',
        unitPrice: 10.5,
        quantity: 2,
        uom: UnitOfMeasure.pack,
      ),
    );
    expect(
      (withPack as Success<ShoppingSession>).value.items.single.uom,
      UnitOfMeasure.pack,
    );
    expect(
      (withPack as Success<ShoppingSession>).value.items.single.uomFactor,
      const Quantity.milli(2000),
    );

    final rejected = await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(
      const UpsertShoppingItemParams(
        productId: 'prod1',
        unitPrice: 10.5,
        uom: UnitOfMeasure.kilogram,
      ),
    );
    expect(rejected.failureOrNull?.code, FailureCode.validation);

    final completed = await CompleteShopping(repository, clock: clock)(
      const NoParams(),
    );
    expect(completed.isSuccess, isTrue);
    expect(repository.inProgress, isNull);
  });

  test('distingue Pq de 3 Und y Pq de 4 Und al agregar un ítem', () async {
    repository.catalogProducts['abc'] = const ShoppingProductRef(
      id: 'abc',
      name: 'ABC',
      isActive: true,
      uomLadder: UomLadder(
        base: UnitOfMeasure.unit,
        steps: [
          UomLadderStep(
            uom: UnitOfMeasure.pack,
            factor: Quantity.milli(3000),
          ),
          UomLadderStep(
            uom: UnitOfMeasure.pack,
            factor: Quantity.milli(4000),
          ),
        ],
      ),
    );
    await StartShopping(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(['s1']),
    )(const StartShoppingParams(marketId: 'm1'));

    final ambiguous = await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(
      const UpsertShoppingItemParams(
        productId: 'abc',
        unitPrice: 12,
        uom: UnitOfMeasure.pack,
      ),
    );
    expect(ambiguous.failureOrNull?.code, FailureCode.validation);

    final packOfThree = await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(
      const UpsertShoppingItemParams(
        productId: 'abc',
        unitPrice: 12,
        uom: UnitOfMeasure.pack,
        uomFactor: 3,
      ),
    );
    final item = (packOfThree as Success<ShoppingSession>).value.items.single;
    expect(item.uom, UnitOfMeasure.pack);
    expect(item.uomFactor, const Quantity.milli(3000));
  });

  test('lista el catálogo activo para mercar', () async {
    repository.catalogProducts['hidden'] = const ShoppingProductRef(
      id: 'hidden',
      name: 'Inactivo',
      isActive: false,
    );
    final result = await ListShoppingCatalog(repository)(
      const ListShoppingCatalogParams(),
    );
    final items = (result as Success<List<ShoppingProductRef>>).value;
    expect(items.map((item) => item.id), ['prod1']);
  });

  test('prioriza sugeridos en el catálogo y al filtrar', () async {
    repository.catalogProducts['leche'] = const ShoppingProductRef(
      id: 'leche',
      name: 'Leche',
      isActive: true,
    );
    repository.catalogProducts['limon'] = const ShoppingProductRef(
      id: 'limon',
      name: 'Limón',
      isActive: true,
      isSuggested: true,
    );
    final listed = await ListShoppingCatalog(repository)(
      const ListShoppingCatalogParams(),
    );
    expect(
      (listed as Success<List<ShoppingProductRef>>).value.map((item) => item.id),
      ['limon', 'prod1', 'leche'],
    );

    final filtered = await ListShoppingCatalog(repository)(
      const ListShoppingCatalogParams(nameQuery: 'l'),
    );
    expect(
      (filtered as Success<List<ShoppingProductRef>>).value.map((item) => item.id),
      ['limon', 'leche'],
    );
  });

  test('completar la compra quita la sugerencia de los productos comprados', () async {
    repository.catalogProducts['prod1'] = const ShoppingProductRef(
      id: 'prod1',
      name: 'Arroz',
      isActive: true,
      isSuggested: true,
    );
    await StartShopping(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(['s1']),
    )(const StartShoppingParams(marketId: 'm1'));
    await UpsertShoppingItem(
      repository,
      idGenerator: SequentialIdGenerator(['i1']),
    )(const UpsertShoppingItemParams(productId: 'prod1', unitPrice: 10));
    await CompleteShopping(repository, clock: clock)(const NoParams());
    expect(repository.catalogProducts['prod1']?.isSuggested, isFalse);
  });
}
