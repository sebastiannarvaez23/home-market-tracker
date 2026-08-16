import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/catalog_validator.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';

class UpdateMarketParams {
  const UpdateMarketParams({
    required this.id,
    required this.name,
    this.location,
    this.notes,
  });

  final String id;
  final String name;
  final String? location;
  final String? notes;
}

class UpdateMarket extends UseCase<Market, UpdateMarketParams> {
  UpdateMarket(this._repository, {required Clock clock}) : _clock = clock;

  final MarketRepository _repository;
  final Clock _clock;

  @override
  Future<Result<Market>> call(UpdateMarketParams params) async {
    final nameResult = CatalogValidator.name(params.name);
    if (nameResult is FailureResult<String>) {
      return Result.failure(nameResult.failure);
    }
    final locationResult = CatalogValidator.location(params.location);
    if (locationResult is FailureResult<String?>) {
      return Result.failure(locationResult.failure);
    }
    final notesResult = CatalogValidator.notes(params.notes);
    if (notesResult is FailureResult<String?>) {
      return Result.failure(notesResult.failure);
    }
    final name = (nameResult as Success<String>).value;
    final location = (locationResult as Success<String?>).value;
    final notes = (notesResult as Success<String?>).value;
    final normalized = CatalogValidator.normalizedName(name);

    final currentResult = await _repository.getById(params.id);
    if (currentResult is FailureResult<Market>) {
      return currentResult;
    }
    final current = (currentResult as Success<Market>).value;
    if (!current.isActive) {
      return const Result.failure(
        Failure.inactive('No se puede editar un mercado eliminado.'),
      );
    }

    final existingResult = await _repository.findByNormalizedName(normalized);
    if (existingResult is FailureResult<Market?>) {
      return Result.failure(existingResult.failure);
    }
    final existing = (existingResult as Success<Market?>).value;
    if (existing != null && existing.id != current.id) {
      return const Result.failure(
        Failure.conflict('Ya existe un mercado con ese nombre.'),
      );
    }

    return _repository.update(
      current.copyWith(
        name: name,
        nameNormalized: normalized,
        location: location,
        clearLocation: location == null,
        notes: notes,
        clearNotes: notes == null,
        updatedAt: _clock.nowEpochMs(),
      ),
    );
  }
}
