import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class SuggestProduct extends UseCase<Product, String> {
  SuggestProduct(this._repository, {required Clock clock}) : _clock = clock;

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
      return const Result.failure(
        Failure.inactive('No se puede sugerir un producto eliminado.'),
      );
    }
    if (current.isSuggested) {
      return Result.success(current);
    }
    return _repository.update(
      current.copyWith(
        isSuggested: true,
        updatedAt: _clock.nowEpochMs(),
      ),
    );
  }
}
