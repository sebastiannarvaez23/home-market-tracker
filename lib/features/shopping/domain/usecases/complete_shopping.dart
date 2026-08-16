import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class CompleteShopping extends UseCase<ShoppingSession, NoParams> {
  CompleteShopping(this._repository, {required Clock clock}) : _clock = clock;

  final ShoppingRepository _repository;
  final Clock _clock;

  @override
  Future<Result<ShoppingSession>> call(NoParams params) async {
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
    if (session.items.isEmpty) {
      return const Result.failure(
        Failure.precondition('No se puede completar una compra sin productos.'),
      );
    }
    return _repository.complete(
      sessionId: session.id,
      completedAt: _clock.nowEpochMs(),
    );
  }
}
