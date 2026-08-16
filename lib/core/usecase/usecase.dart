import 'package:home_market_tracker/core/result/result.dart';

abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

class NoParams {
  const NoParams();
}
