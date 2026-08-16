import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/utils/catalog_validator.dart';
import 'package:home_market_tracker/core/value/quantity.dart';
import 'package:home_market_tracker/core/value/unit_of_measure.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/create_product.dart';
import 'package:home_market_tracker/features/products/domain/usecases/soft_delete_product.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryProductRepository repository;
  late FakeProductPhotoStorage photos;
  late FakeClock clock;
  late SequentialIdGenerator ids;
  late CreateProduct createProduct;

  CreateProductParams params(
    String name, {
    String? notes,
    String photoSourcePath = testPhotoSourcePath,
    UomLadderDraft uomLadder = const UomLadderDraft(),
  }) {
    return CreateProductParams(
      name: name,
      notes: notes,
      photoSourcePath: photoSourcePath,
      uomLadder: uomLadder,
    );
  }

  CreateProduct buildCreate({List<String> nextIds = const ['p2']}) {
    return CreateProduct(
      repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(nextIds),
      photos: photos,
    );
  }

  setUp(() {
    repository = InMemoryProductRepository();
    photos = FakeProductPhotoStorage();
    clock = FakeClock(DateTime(2026, 8, 14, 10));
    ids = SequentialIdGenerator(['p1']);
    createProduct = CreateProduct(
      repository,
      clock: clock,
      idGenerator: ids,
      photos: photos,
    );
  });

  test('normaliza el nombre y colapsa espacios', () {
    expect(CatalogValidator.normalizedName('  Café   Molido '), 'café molido');
  });

  test('rechaza nombre vacío', () async {
    final result = await createProduct(params('   '));
    expect(result.failureOrNull?.code, FailureCode.validation);
  });

  test('rechaza crear sin foto', () async {
    final result = await createProduct(params('Leche', photoSourcePath: '  '));
    expect(result.failureOrNull?.code, FailureCode.validation);
    expect(result.failureOrNull?.message, 'La foto del producto es obligatoria.');
    expect(repository.products, isEmpty);
  });

  test('crea un producto activo con foto', () async {
    final result = await createProduct(params('Leche', notes: 'entera'));
    final product = (result as Success<Product>).value;
    expect(product.id, 'p1');
    expect(product.nameNormalized, 'leche');
    expect(product.isActive, isTrue);
    expect(product.photoPath, 'product_photos/p1.jpg');
    expect(photos.saved['p1'], testPhotoSourcePath);
  });

  test('conflicto si el nombre ya existe y está activo', () async {
    await createProduct(params('Leche'));
    final result = await buildCreate()(params('leche'));
    expect(result.failureOrNull?.code, FailureCode.conflict);
  });

  test('reactiva un producto inactivo con el mismo nombre y nueva foto', () async {
    await createProduct(params('Leche'));
    await SoftDeleteProduct(repository, clock: clock)('p1');
    final result = await buildCreate()(
      params('Leche', notes: 'deslactosada', photoSourcePath: 'memory://nueva'),
    );
    final product = (result as Success<Product>).value;
    expect(product.id, 'p1');
    expect(product.isActive, isTrue);
    expect(product.notes, 'deslactosada');
    expect(product.photoPath, 'product_photos/p1.jpg');
    expect(photos.saved['p1'], 'memory://nueva');
    expect(repository.products.length, 1);
  });

  test('persiste una escalera Pq → 2 Und', () async {
    final result = await createProduct(
      params(
        'Huevos',
        uomLadder: const UomLadderDraft(
          base: UnitOfMeasure.unit,
          steps: [
            UomStepDraft(uom: UnitOfMeasure.pack, factor: 2),
          ],
        ),
      ),
    );
    final product = (result as Success<Product>).value;
    expect(product.uomLadder.base, UnitOfMeasure.unit);
    expect(product.uomLadder.steps.single.uom, UnitOfMeasure.pack);
    expect(product.uomLadder.steps.single.factor, const Quantity.milli(2000));
  });

  test('persiste dos tamaños del mismo UoM: Pq 3 Und y Pq 4 Und', () async {
    final result = await createProduct(
      params(
        'ABC',
        uomLadder: const UomLadderDraft(
          base: UnitOfMeasure.unit,
          steps: [
            UomStepDraft(uom: UnitOfMeasure.pack, factor: 3),
            UomStepDraft(uom: UnitOfMeasure.pack, factor: 4),
          ],
        ),
      ),
    );
    final product = (result as Success<Product>).value;
    expect(product.uomLadder.steps, hasLength(2));
    expect(product.uomLadder.steps[0].factor, const Quantity.milli(3000));
    expect(product.uomLadder.steps[1].factor, const Quantity.milli(4000));
  });
}
