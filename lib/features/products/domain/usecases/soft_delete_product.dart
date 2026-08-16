import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class SoftDeleteProduct extends UseCase<Product, String> {
  SoftDeleteProduct(this._repository, {required Clock clock}) : _clock = clock;

  final ProductRepository _repository;
  final Clock _clock;

  @override
  Future<Result<Product>> call(String params) async {
    final currentResult = await _repository.getById(params);
    if (currentResult is FailureResult<Product>) {
      return currentResult;
    }
    final current = (currentResult as Success<Product>).value;
    if (!current.isActive) {
      return Result.success(current);
    }
    return _repository.update(
      current.copyWith(
        isActive: false,
        updatedAt: _clock.nowEpochMs(),
      ),
    );
  }
}
