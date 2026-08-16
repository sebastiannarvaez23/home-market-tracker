import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/suggest_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/unsuggest_product.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryProductRepository repository;
  late FakeClock clock;

  Product product({bool isActive = true, bool isSuggested = false}) {
    return Product(
      id: 'p1',
      name: 'Arroz',
      nameNormalized: 'arroz',
      notes: null,
      isActive: isActive,
      createdAt: 1,
      updatedAt: 1,
      isSuggested: isSuggested,
    );
  }

  setUp(() {
    repository = InMemoryProductRepository();
    clock = FakeClock(DateTime(2026, 8, 15));
  });

  test('sugiere un producto activo', () async {
    repository.products['p1'] = product();
    final result = await SuggestProduct(repository, clock: clock)('p1');
    final value = (result as Success<Product>).value;
    expect(value.isSuggested, isTrue);
  });

  test('no sugiere un producto inactivo', () async {
    repository.products['p1'] = product(isActive: false);
    final result = await SuggestProduct(repository, clock: clock)('p1');
    expect(result.failureOrNull?.code, FailureCode.inactive);
  });

  test('quita la sugerencia', () async {
    repository.products['p1'] = product(isSuggested: true);
    final result = await UnsuggestProduct(repository, clock: clock)('p1');
    expect((result as Success<Product>).value.isSuggested, isFalse);
  });
}
