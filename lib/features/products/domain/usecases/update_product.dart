import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/catalog_validator.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class UpdateProductParams {
  const UpdateProductParams({
    required this.id,
    required this.name,
    this.notes,
    this.uomLadder,
  });

  final String id;
  final String name;
  final String? notes;
  final UomLadderDraft? uomLadder;
}

class UpdateProduct extends UseCase<Product, UpdateProductParams> {
  UpdateProduct(this._repository, {required Clock clock}) : _clock = clock;

  final ProductRepository _repository;
  final Clock _clock;

  @override
  Future<Result<Product>> call(UpdateProductParams params) async {
    final nameResult = CatalogValidator.name(params.name);
    if (nameResult is FailureResult<String>) {
      return Result.failure(nameResult.failure);
    }
    final notesResult = CatalogValidator.notes(params.notes);
    if (notesResult is FailureResult<String?>) {
      return Result.failure(notesResult.failure);
    }
    final name = (nameResult as Success<String>).value;
    final notes = (notesResult as Success<String?>).value;
    final normalized = CatalogValidator.normalizedName(name);

    UomLadder? parsedLadder;
    if (params.uomLadder != null) {
      final ladderResult = UomLadder.parse(params.uomLadder!);
      if (ladderResult is FailureResult<UomLadder>) {
        return Result.failure(ladderResult.failure);
      }
      parsedLadder = (ladderResult as Success<UomLadder>).value;
    }

    final currentResult = await _repository.getById(params.id);
    if (currentResult is FailureResult<Product>) {
      return currentResult;
    }
    final current = (currentResult as Success<Product>).value;
    if (!current.isActive) {
      return const Result.failure(
        Failure.inactive('No se puede editar un producto eliminado.'),
      );
    }

    final existingResult = await _repository.findByNormalizedName(normalized);
    if (existingResult is FailureResult<Product?>) {
      return Result.failure(existingResult.failure);
    }
    final existing = (existingResult as Success<Product?>).value;
    if (existing != null && existing.id != current.id) {
      return const Result.failure(
        Failure.conflict('Ya existe un producto con ese nombre.'),
      );
    }

    return _repository.update(
      current.copyWith(
        name: name,
        nameNormalized: normalized,
        notes: notes,
        clearNotes: notes == null,
        uomLadder: parsedLadder,
        updatedAt: _clock.nowEpochMs(),
      ),
    );
  }
}
