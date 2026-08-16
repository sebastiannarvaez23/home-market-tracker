import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/id/id_generator.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/catalog_validator.dart';
import 'package:home_market_tracker/features/markets/domain/entities/market.dart';
import 'package:home_market_tracker/features/markets/domain/repositories/market_repository.dart';

class CreateMarketParams {
  const CreateMarketParams({
    required this.name,
    this.location,
    this.notes,
  });

  final String name;
  final String? location;
  final String? notes;
}

class CreateMarket extends UseCase<Market, CreateMarketParams> {
  CreateMarket(
    this._repository, {
    required Clock clock,
    required IdGenerator idGenerator,
  })  : _clock = clock,
        _idGenerator = idGenerator;

  final MarketRepository _repository;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<Result<Market>> call(CreateMarketParams params) async {
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

    final existingResult = await _repository.findByNormalizedName(normalized);
    if (existingResult is FailureResult<Market?>) {
      return Result.failure(existingResult.failure);
    }
    final existing = (existingResult as Success<Market?>).value;
    final now = _clock.nowEpochMs();

    if (existing != null) {
      if (existing.isActive) {
        return const Result.failure(
          Failure.conflict('Ya existe un mercado con ese nombre.'),
        );
      }
      return _repository.update(
        existing.copyWith(
          name: name,
          nameNormalized: normalized,
          location: location,
          clearLocation: location == null,
          notes: notes,
          clearNotes: notes == null,
          isActive: true,
          updatedAt: now,
        ),
      );
    }

    return _repository.insert(
      Market(
        id: _idGenerator.next(),
        name: name,
        nameNormalized: normalized,
        location: location,
        notes: notes,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
