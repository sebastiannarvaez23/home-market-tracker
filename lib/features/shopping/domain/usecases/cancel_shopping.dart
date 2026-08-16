import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class CancelShopping extends UseCase<void, NoParams> {
  CancelShopping(this._repository);

  final ShoppingRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) async {
    final sessionResult = await _repository.findInProgress();
    if (sessionResult is FailureResult<ShoppingSession?>) {
      return Result.failure(sessionResult.failure);
    }
    final session = (sessionResult as Success<ShoppingSession?>).value;
    if (session == null) {
      return const Result.failure(
        Failure.precondition('No hay una compra en curso.'),
      );
    }
    return _repository.deleteInProgress(session.id);
  }
}
