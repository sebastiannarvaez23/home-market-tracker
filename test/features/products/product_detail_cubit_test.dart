import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/usecases/get_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/list_product_purchase_history.dart';
import 'package:home_market_tracker/features/products/domain/usecases/suggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/unsuggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/update_product.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_cubit.dart';
import 'package:home_market_tracker/features/products/presentation/bloc/product_detail_state.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryProductRepository repository;
  late ProductDetailCubit cubit;

  Product product({
    String id = 'p1',
    String name = 'Arroz',
    String? notes,
  }) {
    return Product(
      id: id,
      name: name,
      nameNormalized: name.toLowerCase(),
      notes: notes,
      isActive: true,
      createdAt: 1,
      updatedAt: 1,
    );
  }

  ProductDetailCubit buildCubit({
    String productId = 'p1',
    InMemoryProductRepository? repo,
  }) {
    final resolved = repo ?? repository;
    final clock = FakeClock(DateTime(2026, 8, 15));
    return ProductDetailCubit(
      productId,
      GetProduct(resolved),
      UpdateProduct(resolved, clock: clock),
      ListProductPurchaseHistory(resolved),
      SuggestProduct(resolved, clock: clock),
      UnsuggestProduct(resolved, clock: clock),
    );
  }

  setUp(() {
    repository = InMemoryProductRepository();
    cubit = buildCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  blocTest<ProductDetailCubit, ProductDetailState>(
    'carga el producto y el historial del más nuevo al más antiguo',
    build: () {
      repository.products['p1'] = product();
      repository.purchaseHistory['p1'] = const [
        ProductPurchaseHistoryEntry(
          id: 'old',
          marketName: 'Jumbo',
          unitPrice: Money.cents(180000),
          quantity: Quantity.milli(1000),
          uom: UnitOfMeasure.unit,
          purchasedAt: 100,
        ),
        ProductPurchaseHistoryEntry(
          id: 'new',
          marketName: 'Éxito',
          unitPrice: Money.cents(200000),
          quantity: Quantity.milli(1000),
          uom: UnitOfMeasure.kilogram,
          purchasedAt: 200,
        ),
      ];
      return cubit;
    },
    act: (cubit) => cubit.started(),
    verify: (cubit) {
      expect(cubit.state.status, ProductDetailStatus.data);
      expect(cubit.state.product?.name, 'Arroz');
      expect(cubit.state.history, hasLength(2));
      expect(cubit.state.history.first.marketName, 'Éxito');
      expect(cubit.state.history.last.marketName, 'Jumbo');
    },
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'actualiza el producto al guardar',
    build: () {
      repository.products['p1'] = product(notes: 'grano largo');
      return cubit;
    },
    act: (cubit) async {
      await cubit.started();
      await cubit.saveProduct(name: 'Arroz blanco', notes: 'integral');
    },
    verify: (cubit) {
      expect(cubit.state.status, ProductDetailStatus.data);
      expect(cubit.state.product?.name, 'Arroz blanco');
      expect(cubit.state.product?.notes, 'integral');
      expect(cubit.state.saveFailure, isNull);
    },
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'marca el producto como sugerido',
    build: () {
      repository.products['p1'] = product();
      return cubit;
    },
    act: (cubit) async {
      await cubit.started();
      await cubit.suggestionToggled();
    },
    verify: (cubit) {
      expect(cubit.state.product?.isSuggested, isTrue);
    },
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'emite error cuando el producto no existe',
    build: () => cubit,
    act: (cubit) => cubit.started(),
    expect: () => [
      isA<ProductDetailState>()
          .having((s) => s.status, 'status', ProductDetailStatus.loading),
      isA<ProductDetailState>()
          .having((s) => s.status, 'status', ProductDetailStatus.error)
          .having((s) => s.failure?.code, 'code', FailureCode.notFound),
    ],
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'emite error cuando falla el historial',
    build: () => buildCubit(repo: _FailingHistoryRepository()),
    act: (cubit) => cubit.started(),
    verify: (cubit) {
      expect(cubit.state.status, ProductDetailStatus.error);
      expect(cubit.state.failure?.code, FailureCode.storage);
    },
  );
}

class _FailingHistoryRepository extends InMemoryProductRepository {
  _FailingHistoryRepository() {
    products['p1'] = const Product(
      id: 'p1',
      name: 'Arroz',
      nameNormalized: 'arroz',
      notes: null,
      isActive: true,
      createdAt: 1,
      updatedAt: 1,
    );
  }

  @override
  Future<Result<List<ProductPurchaseHistoryEntry>>> listPurchaseHistory(
    String productId,
  ) async {
    return const Result.failure(Failure.storage('disk'));
  }
}
