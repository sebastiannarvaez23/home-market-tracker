import 'package:get_it/get_it.dart';
import 'package:home_market_tracker/core/database/app_database.dart';
import 'package:home_market_tracker/core/database/sqlite_platform.dart';
import 'package:home_market_tracker/core/id/id_generator.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:home_market_tracker/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:home_market_tracker/features/dashboard/data/repositories/market_suggestion_repository_impl.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:home_market_tracker/features/dashboard/domain/repositories/market_suggestion_repository.dart';
import 'package:home_market_tracker/features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import 'package:home_market_tracker/features/dashboard/domain/usecases/get_market_price_suggestions.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:home_market_tracker/features/dashboard/presentation/bloc/market_suggestions_cubit.dart';
import 'package:home_market_tracker/features/history/data/datasources/history_local_data_source.dart';
import 'package:home_market_tracker/features/history/data/repositories/history_repository_impl.dart';
import 'package:home_market_tracker/features/history/domain/repositories/history_repository.dart';
import 'package:home_market_tracker/features/history/domain/usecases/get_shopping_detail.dart';
import 'package:home_market_tracker/features/history/domain/usecases/list_completed_shoppings.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_detail_cubit.dart';
import 'package:home_market_tracker/features/history/presentation/bloc/history_list_cubit.dart';
import 'package:home_market_tracker/features/markets/data/datasources/market_local_data_source.dart';
import 'package:home_market_tracker/features/markets/data/repositories/market_repository_impl.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/create_market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/get_market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/list_markets.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/soft_delete_market.dart';
import 'package:home_market_tracker/features/markets/domain/usecases/update_market.dart';
import 'package:home_market_tracker/features/markets/presentation/bloc/pick_market_cubit.dart';
import 'package:home_market_tracker/features/products/data/datasources/product_local_data_source.dart';
import 'package:home_market_tracker/features/products/data/datasources/product_photo_storage_impl.dart';
import 'package:home_market_tracker/features/products/data/repositories/product_repository_impl.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_photo_storage.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';
import 'package:home_market_tracker/features/products/domain/usecases/create_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/get_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_product_purchase_history.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_products.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_products_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/usecases/soft_delete_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/suggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/unsuggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/update_product.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_cubit.dart';
import 'package:home_market_tracker/features/shopping/data/datasources/shopping_local_data_source.dart';
import 'package:home_market_tracker/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/cancel_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/complete_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/get_in_progress_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/list_shopping_catalog.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/remove_shopping_item.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/start_shopping.dart';
import 'package:home_market_tracker/features/shopping/domain/usecases/upsert_shopping_item.dart';
import 'package:home_market_tracker/features/shopping/presentation/bloc/shopping_session_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies({
  AppDatabase? database,
  Clock? clock,
  IdGenerator? idGenerator,
}) async {
  await sl.reset();
  ensureSqliteForPlatform();

  sl.registerSingleton<Clock>(clock ?? const SystemClock());
  sl.registerSingleton<IdGenerator>(idGenerator ?? UuidGenerator());

  final appDatabase = database ?? AppDatabase(pathResolver: AppDatabase.documentsPath);
  sl.registerSingleton<AppDatabase>(appDatabase);
  await appDatabase.connection;

  sl.registerLazySingleton<ProductPhotoStorage>(
    () => ProductPhotoStorageImpl(),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MarketLocalDataSource>(
    () => MarketLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ShoppingLocalDataSource>(
    () => ShoppingLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MarketSuggestionRepository>(
    () => MarketSuggestionRepositoryImpl(sl()),
  );

  sl.registerFactory(() => ListProducts(sl()));
  sl.registerFactory(() => ListProductsWithLastPurchase(sl()));
  sl.registerFactory(() => ListProductPurchaseHistory(sl()));
  sl.registerFactory(() => GetProduct(sl()));
  sl.registerFactory(
    () => CreateProduct(
      sl(),
      clock: sl(),
      idGenerator: sl(),
      photos: sl(),
    ),
  );
  sl.registerFactory(() => UpdateProduct(sl(), clock: sl()));
  sl.registerFactory(() => SoftDeleteProduct(sl(), clock: sl()));
  sl.registerFactory(() => SuggestProduct(sl(), clock: sl()));
  sl.registerFactory(() => UnsuggestProduct(sl(), clock: sl()));
  sl.registerFactory(() => ProductsListCubit(sl(), sl()));
  sl.registerFactoryParam<ProductDetailCubit, String, void>(
    (productId, _) => ProductDetailCubit(
      productId,
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory(() => ListMarkets(sl()));
  sl.registerFactory(() => GetMarket(sl()));
  sl.registerFactory(
    () => CreateMarket(sl(), clock: sl(), idGenerator: sl()),
  );
  sl.registerFactory(() => UpdateMarket(sl(), clock: sl()));
  sl.registerFactory(() => SoftDeleteMarket(sl(), clock: sl()));
  sl.registerFactory(() => PickMarketCubit(sl(), sl()));

  sl.registerFactory(
    () => StartShopping(sl(), clock: sl(), idGenerator: sl()),
  );
  sl.registerFactory(() => GetInProgressShopping(sl()));
  sl.registerFactory(() => ListShoppingCatalog(sl()));
  sl.registerFactory(() => UpsertShoppingItem(sl(), idGenerator: sl()));
  sl.registerFactory(() => RemoveShoppingItem(sl()));
  sl.registerFactory(() => CompleteShopping(sl(), clock: sl()));
  sl.registerFactory(() => CancelShopping(sl()));
  sl.registerFactory(
    () => ShoppingSessionCubit(
      getInProgress: sl(),
      listCatalog: sl(),
      upsertItem: sl(),
      completeShopping: sl(),
      cancelShopping: sl(),
    ),
  );

  sl.registerFactory(() => ListCompletedShoppings(sl()));
  sl.registerFactory(() => GetShoppingDetail(sl()));
  sl.registerFactory(() => HistoryListCubit(sl()));
  sl.registerFactoryParam<HistoryDetailCubit, String, void>(
    (sessionId, _) => HistoryDetailCubit(sessionId, sl()),
  );

  sl.registerFactory(() => GetDashboardSnapshot(sl(), clock: sl()));
  sl.registerFactory(() => DashboardCubit(sl()));
  sl.registerFactory(() => GetMarketPriceSuggestions(sl()));
  sl.registerFactory(() => MarketSuggestionsCubit(sl()));
}
