import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/products/data/datasources/product_local_data_source.dart';
import 'package:home_market_tracker/features/products/data/repositories/product_repository_impl.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/usecases/create_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_products_with_last_purchase.dart';
import 'package:home_market_tracker/features/markets/data/datasources/market_local_data_source.dart';
import 'package:home_market_tracker/features/markets/data/repositories/market_repository_impl.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/create_market.dart';
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

  test('flujo SQLite: compra completada alimenta última compra del producto', () async {
    final database = AppDatabase(
      pathResolver: () async => inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    addTearDown(database.close);

    final clock = FakeClock(DateTime(2026, 8, 14, 18));
    final ids = SequentialIdGenerator(['m1', 'p1', 's1', 'i1']);

    final markets = MarketRepositoryImpl(MarketLocalDataSourceImpl(database));
    final products = ProductRepositoryImpl(ProductLocalDataSourceImpl(database));
    final shopping = ShoppingRepositoryImpl(ShoppingLocalDataSourceImpl(database));

    final market = await CreateMarket(
      markets,
      clock: clock,
      idGenerator: ids,
    )(const CreateMarketParams(name: 'Jumbo'));
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

    await StartShopping(
      shopping,
      clock: clock,
      idGenerator: ids,
    )(StartShoppingParams(marketId: market.valueOrNull!.id));

    await UpsertShoppingItem(
      shopping,
      idGenerator: ids,
    )(
      UpsertShoppingItemParams(
        productId: product.valueOrNull!.id,
        unitPrice: 18500,
        quantity: 1,
      ),
    );

    await CompleteShopping(shopping, clock: clock)(const NoParams());

    final listed = await ListProductsWithLastPurchase(products)(
      const ListProductsWithLastPurchaseParams(),
    );
    final row = (listed as Success<List<ProductWithLastPurchase>>).value.single;
    expect(row.lastPurchase, isNotNull);
    expect(row.lastPurchase!.marketName, 'Jumbo');
    expect(row.lastPurchase!.unitPrice, const Money.cents(1850000));
    expect(row.lastPurchase!.uom, UnitOfMeasure.unit);
  });
}
