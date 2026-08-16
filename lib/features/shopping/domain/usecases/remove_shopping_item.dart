import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class RemoveShoppingItemParams {
  const RemoveShoppingItemParams({required this.itemId});

  final String itemId;
}

class RemoveShoppingItem
    extends UseCase<ShoppingSession, RemoveShoppingItemParams> {
  RemoveShoppingItem(this._repository);

  final ShoppingRepository _repository;

  @override
  Future<Result<ShoppingSession>> call(RemoveShoppingItemParams params) async {
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
    final exists = session.items.any((item) => item.id == params.itemId);
    if (!exists) {
      return const Result.failure(
        Failure.notFound('El producto no está en la compra actual.'),
      );
    }
    return _repository.removeItem(
      sessionId: session.id,
      itemId: params.itemId,
    );
  }
}
