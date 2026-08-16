import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class ListProductPurchaseHistory
    extends UseCase<List<ProductPurchaseHistoryEntry>, String> {
  ListProductPurchaseHistory(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<ProductPurchaseHistoryEntry>>> call(String params) {
    return _repository.listPurchaseHistory(params);
  }
}
