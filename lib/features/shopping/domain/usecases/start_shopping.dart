import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/id/id_generator.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_session_status.dart';
import 'package:home_market_tracker/features/shopping/domain/repositories/shopping_repository.dart';

class StartShoppingParams {
  const StartShoppingParams({required this.marketId});

  final String marketId;
}

class StartShopping extends UseCase<ShoppingSession, StartShoppingParams> {
  StartShopping(
    this._repository, {
    required Clock clock,
    required IdGenerator idGenerator,
  })  : _clock = clock,
        _idGenerator = idGenerator;

  final ShoppingRepository _repository;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<Result<ShoppingSession>> call(StartShoppingParams params) async {
    final currentResult = await _repository.findInProgress();
    if (currentResult is FailureResult<ShoppingSession?>) {
      return Result.failure(currentResult.failure);
    }
    final current = (currentResult as Success<ShoppingSession?>).value;
    if (current != null) {
      return const Result.failure(
        Failure.conflict(
          'Ya hay una compra en curso. Complétala o cancélala antes de iniciar otra.',
        ),
      );
    }

    final marketResult = await _repository.getMarket(params.marketId);
    if (marketResult is FailureResult<ShoppingMarketRef>) {
      return Result.failure(marketResult.failure);
    }
    final market = (marketResult as Success<ShoppingMarketRef>).value;
    if (!market.isActive) {
      return const Result.failure(
        Failure.inactive('No se puede iniciar una compra en un mercado eliminado.'),
      );
    }

    return _repository.insertSession(
      ShoppingSession(
        id: _idGenerator.next(),
        marketId: market.id,
        marketNameSnapshot: market.name,
        status: ShoppingSessionStatus.inProgress,
        startedAt: _clock.nowEpochMs(),
        completedAt: null,
        items: const [],
      ),
    );
  }
}
