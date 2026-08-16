import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class GetProduct extends UseCase<Product, String> {
  GetProduct(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(String params) {
    return _repository.getById(params);
  }
}
