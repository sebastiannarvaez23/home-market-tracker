import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/features/markets/data/datasources/market_local_data_source.dart';
import 'package:home_market_tracker/features/markets/data/repositories/market_repository_impl.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/create_market.dart';
import 'package:home_market_tracker/features/products/data/datasources/product_local_data_source.dart';
import 'package:home_market_tracker/features/products/data/repositories/product_repository_impl.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/usecases/create_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_product_purchase_history.dart';
import 'package:home_market_tracker/features/shopping/data/datasources/shopping_local_data_source.dart';
import 'package:home_market_tracker/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/complete_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/start_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/upsert_shopping_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fakes.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test(
    'historial SQLite: compras completadas del más nuevo al más antiguo',
    () async {
      final database = AppDatabase(
        pathResolver: () async => inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      addTearDown(database.close);

      final clock = FakeClock(DateTime(2026, 8, 14, 10));
      final ids = SequentialIdGenerator([
        'm1',
        'm2',
        'p1',
        's1',
        'i1',
        's2',
        'i2',
        's3',
        'i3',
      ]);

      final markets = MarketRepositoryImpl(MarketLocalDataSourceImpl(database));
      final products =
          ProductRepositoryImpl(ProductLocalDataSourceImpl(database));
      final shopping =
          ShoppingRepositoryImpl(ShoppingLocalDataSourceImpl(database));

      final jumbo = await CreateMarket(
        markets,
        clock: clock,
        idGenerator: ids,
      )(const CreateMarketParams(name: 'Jumbo'));
      final exito = await CreateMarket(
        markets,
        clock: clock,
        idGenerator: ids,
      )(const CreateMarketParams(name: 'Éxito'));
      final product = await CreateProduct(
        products,
        clock: clock,
        idGenerator: ids,
        photos: FakeProductPhotoStorage(),
      )(
        const CreateProductParams(
          name: 'Huevos',
          photoSourcePath: testPhotoSourcePath,
        ),
      );

      final start = StartShopping(
        shopping,
        clock: clock,
        idGenerator: ids,
      );
      final upsert = UpsertShoppingItem(shopping, idGenerator: ids);
      final complete = CompleteShopping(shopping, clock: clock);
      final productId = product.valueOrNull!.id;

      await start(StartShoppingParams(marketId: jumbo.valueOrNull!.id));
      await upsert(
        UpsertShoppingItemParams(productId: productId, unitPrice: 18500),
      );
      await complete(const NoParams());

      clock.current = DateTime(2026, 8, 15, 18);
      await start(StartShoppingParams(marketId: exito.valueOrNull!.id));
      await upsert(
        UpsertShoppingItemParams(productId: productId, unitPrice: 20000),
      );
      await complete(const NoParams());

      clock.current = DateTime(2026, 8, 16, 9);
      await start(StartShoppingParams(marketId: jumbo.valueOrNull!.id));
      await upsert(
        UpsertShoppingItemParams(productId: productId, unitPrice: 999),
      );

      final history = await ListProductPurchaseHistory(products)(productId);
      final rows =
          (history as Success<List<ProductPurchaseHistoryEntry>>).value;

      expect(rows, hasLength(2));
      expect(rows.first.marketName, 'Éxito');
      expect(rows.first.unitPrice, const Money.cents(2000000));
      expect(rows.last.marketName, 'Jumbo');
      expect(rows.last.unitPrice, const Money.cents(1850000));
    },
  );
}
