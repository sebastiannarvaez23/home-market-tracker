import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/products/data/datasources/product_photo_storage_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('hmt_photos_');
  });

  tearDown(() async {
    if (await temp.exists()) {
      await temp.delete(recursive: true);
    }
  });

  test('copia la foto a product_photos/{id}.jpg', () async {
    final source = File(p.join(temp.path, 'taken.jpg'));
    await source.writeAsBytes(const [1, 2, 3, 4]);
    final storage = ProductPhotoStorageImpl(
      documentsPathResolver: () async => temp.path,
    );

    final result = await storage.persist(
      productId: 'p1',
      sourcePath: source.path,
    );

    final relative = (result as Success<String>).value;
    expect(relative, 'product_photos/p1.jpg');
    final saved = File(p.join(temp.path, 'product_photos', 'p1.jpg'));
    expect(await saved.exists(), isTrue);
    expect(await saved.readAsBytes(), const [1, 2, 3, 4]);
  });

  test('falla si el archivo fuente no existe', () async {
    final storage = ProductPhotoStorageImpl(
      documentsPathResolver: () async => temp.path,
    );

    final result = await storage.persist(
      productId: 'p1',
      sourcePath: p.join(temp.path, 'missing.jpg'),
    );

    expect(result.failureOrNull?.code, FailureCode.validation);
  });
}
