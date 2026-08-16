import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';

class SoftDeleteMarket extends UseCase<Market, String> {
  SoftDeleteMarket(this._repository, {required Clock clock}) : _clock = clock;

  final MarketRepository _repository;
  final Clock _clock;

  @override
  Future<Result<Market>> call(String params) async {
    final currentResult = await _repository.getById(params);
    if (currentResult is FailureResult<Market>) {
      return currentResult;
    }
    final current = (currentResult as Success<Market>).value;
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
