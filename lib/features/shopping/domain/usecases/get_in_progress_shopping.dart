import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class GetInProgressShopping extends UseCase<ShoppingSession?, NoParams> {
  GetInProgressShopping(this._repository);

  final ShoppingRepository _repository;

  @override
  Future<Result<ShoppingSession?>> call(NoParams params) {
    return _repository.findInProgress();
  }
}
