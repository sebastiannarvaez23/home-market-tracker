import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/domain/usecases/create_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_products_with_last_purchase.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/products_list_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryProductRepository repository;
  late ProductsListCubit cubit;

  Product product(String id, String name) {
    return Product(
      id: id,
      name: name,
      nameNormalized: name.toLowerCase(),
      notes: null,
      isActive: true,
      createdAt: 1,
      updatedAt: 1,
    );
  }

  ProductsListCubit buildCubit({
    InMemoryProductRepository? repo,
    List<String> ids = const ['new-id'],
  }) {
    final resolved = repo ?? repository;
    return ProductsListCubit(
      ListProductsWithLastPurchase(resolved),
      CreateProduct(
        resolved,
        clock: FakeClock(DateTime(2026, 8, 15)),
        idGenerator: SequentialIdGenerator(ids),
        photos: FakeProductPhotoStorage(),
      ),
    );
  }

  setUp(() {
    repository = InMemoryProductRepository();
    cubit = buildCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<ProductsListCubit, ProductsListState>(
    'emite empty cuando no hay productos',
    build: () => cubit,
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<ProductsListState>()
          .having((s) => s.status, 'status', ProductsListStatus.loading),
      isA<ProductsListState>()
          .having((s) => s.status, 'status', ProductsListStatus.empty),
    ],
  );

  blocTest<ProductsListCubit, ProductsListState>(
    'carga productos con última compra',
    build: () {
      repository.products['p1'] = product('p1', 'Arroz');
      repository.products['p2'] = product('p2', 'Leche');
      repository.lastPurchases['p1'] = const ProductLastPurchase(
        marketName: 'Éxito',
        unitPrice: Money.cents(4500),
        uom: UnitOfMeasure.unit,
        purchasedAt: 1,
      );
      return cubit;
    },
    act: (cubit) => cubit.started(),
    verify: (cubit) {
      expect(cubit.state.status, ProductsListStatus.data);
      expect(cubit.state.products, hasLength(2));
      expect(
        cubit.state.products.first.product.name,
        anyOf('Arroz', 'Leche'),
      );
    },
  );

  blocTest<ProductsListCubit, ProductsListState>(
    'crea un producto y recarga el listado',
    build: () => cubit,
    act: (cubit) async {
      await cubit.started();
      await cubit.createProduct(
        name: 'Pan',
        photoSourcePath: testPhotoSourcePath,
      );
    },
    verify: (cubit) {
      expect(cubit.state.status, ProductsListStatus.data);
      expect(cubit.state.products.single.product.name, 'Pan');
      expect(cubit.state.createFailure, isNull);
    },
  );

  blocTest<ProductsListCubit, ProductsListState>(
    'no crea un producto sin foto',
    build: () => cubit,
    act: (cubit) async {
      await cubit.started();
      await cubit.createProduct(name: 'Pan', photoSourcePath: '');
    },
    verify: (cubit) {
      expect(cubit.state.createFailure?.code, FailureCode.validation);
      expect(cubit.state.status, ProductsListStatus.empty);
    },
  );

  blocTest<ProductsListCubit, ProductsListState>(
    'no duplica un producto activo con el mismo nombre',
    build: () {
      repository.products['p1'] = product('p1', 'Arroz');
      return cubit;
    },
    act: (cubit) async {
      await cubit.started();
      await cubit.createProduct(
        name: 'arroz',
        photoSourcePath: testPhotoSourcePath,
      );
    },
    verify: (cubit) {
      expect(cubit.state.createFailure?.code, FailureCode.conflict);
      expect(cubit.state.products, hasLength(1));
    },
  );

  blocTest<ProductsListCubit, ProductsListState>(
    'emite error cuando el repositorio falla',
    build: () {
      return buildCubit(repo: _FailingProductRepository());
    },
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<ProductsListState>()
          .having((s) => s.status, 'status', ProductsListStatus.loading),
      isA<ProductsListState>()
          .having((s) => s.status, 'status', ProductsListStatus.error),
    ],
  );
}

class _FailingProductRepository extends InMemoryProductRepository {
  @override
  Future<Result<List<ProductWithLastPurchase>>> listActiveWithLastPurchase({
    String? nameQuery,
  }) async {
    return const Result.failure(Failure.storage('disk'));
  }
}
