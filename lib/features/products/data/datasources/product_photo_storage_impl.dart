import 'dart:io';

import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_photo_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef DocumentsPathResolver = Future<String> Function();

class ProductPhotoStorageImpl implements ProductPhotoStorage {
  ProductPhotoStorageImpl({DocumentsPathResolver? documentsPathResolver})
      : _documentsPathResolver =
            documentsPathResolver ?? _defaultDocumentsPath;

  static Future<String> _defaultDocumentsPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  static const directoryName = 'product_photos';

  final DocumentsPathResolver _documentsPathResolver;

  @override
  Future<Result<String>> persist({
    required String productId,
    required String sourcePath,
  }) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        return const Result.failure(
          Failure.validation('La foto del producto es obligatoria.'),
        );
      }
      final documents = await _documentsPathResolver();
      final directory = Directory(p.join(documents, directoryName));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final relativePath = p.join(directoryName, '$productId.jpg');
      await source.copy(p.join(documents, relativePath));
      return Result.success(relativePath.replaceAll(r'\', '/'));
    } on FileSystemException {
      return const Result.failure(
        Failure.storage('No se pudo guardar la foto del producto.'),
      );
    }
  }
}
