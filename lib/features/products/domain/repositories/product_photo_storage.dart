import 'package:home_market_tracker/core/result/result.dart';

/// Copia la foto tomada al almacenamiento de la app.
/// Devuelve la ruta relativa a persistir en el producto.
abstract class ProductPhotoStorage {
  Future<Result<String>> persist({
    required String productId,
    required String sourcePath,
  });
}
