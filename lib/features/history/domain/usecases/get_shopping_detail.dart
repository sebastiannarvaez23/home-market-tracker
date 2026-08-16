import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_detail.dart';
import 'package:home_market_tracker/features/history/domain/repositories/history_repository.dart';

class GetShoppingDetail extends UseCase<HistoryDetail, String> {
  GetShoppingDetail(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Result<HistoryDetail>> call(String params) {
    return _repository.getDetail(params);
  }
}
