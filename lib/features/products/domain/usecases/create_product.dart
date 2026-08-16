import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/id/id_generator.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/time/clock.dart';
import 'package:home_market_tracker/core/usecase/usecase.dart';
import 'package:home_market_tracker/core/utils/catalog_validator.dart';
import 'package:home_market_tracker/core/value/uom_ladder.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_photo_storage.dart';
import 'package:home_market_tracker/features/products/domain/repositories/product_repository.dart';

class CreateProductParams {
  const CreateProductParams({
    required this.name,
    required this.photoSourcePath,
    this.notes,
    this.uomLadder = const UomLadderDraft(),
  });

  final String name;
  final String photoSourcePath;
  final String? notes;
  final UomLadderDraft uomLadder;
}

class CreateProduct extends UseCase<Product, CreateProductParams> {
  CreateProduct(
    this._repository, {
    required Clock clock,
    required IdGenerator idGenerator,
    required ProductPhotoStorage photos,
  })  : _clock = clock,
        _idGenerator = idGenerator,
        _photos = photos;

  final ProductRepository _repository;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final ProductPhotoStorage _photos;

  @override
  Future<Result<Product>> call(CreateProductParams params) async {
    final nameResult = CatalogValidator.name(params.name);
    if (nameResult is FailureResult<String>) {
      return Result.failure(nameResult.failure);
    }
    final notesResult = CatalogValidator.notes(params.notes);
    if (notesResult is FailureResult<String?>) {
      return Result.failure(notesResult.failure);
    }
    final photoResult = CatalogValidator.photoSourcePath(params.photoSourcePath);
    if (photoResult is FailureResult<String>) {
      return Result.failure(photoResult.failure);
    }
    final name = (nameResult as Success<String>).value;
    final notes = (notesResult as Success<String?>).value;
    final photoSourcePath = (photoResult as Success<String>).value;
    final normalized = CatalogValidator.normalizedName(name);
    final ladderResult = UomLadder.parse(params.uomLadder);
    if (ladderResult is FailureResult<UomLadder>) {
      return Result.failure(ladderResult.failure);
    }
    final uomLadder = (ladderResult as Success<UomLadder>).value;

    final existingResult = await _repository.findByNormalizedName(normalized);
    if (existingResult is FailureResult<Product?>) {
      return Result.failure(existingResult.failure);
    }
    final existing = (existingResult as Success<Product?>).value;
    final now = _clock.nowEpochMs();

    if (existing != null) {
      if (existing.isActive) {
        return const Result.failure(
          Failure.conflict('Ya existe un producto con ese nombre.'),
        );
      }
      final photoPathResult = await _photos.persist(
        productId: existing.id,
        sourcePath: photoSourcePath,
      );
      if (photoPathResult is FailureResult<String>) {
        return Result.failure(photoPathResult.failure);
      }
      return _repository.update(
        existing.copyWith(
          name: name,
          nameNormalized: normalized,
          notes: notes,
          clearNotes: notes == null,
          isActive: true,
          uomLadder: uomLadder,
          photoPath: (photoPathResult as Success<String>).value,
          updatedAt: now,
        ),
      );
    }

    final id = _idGenerator.next();
    final photoPathResult = await _photos.persist(
      productId: id,
      sourcePath: photoSourcePath,
    );
    if (photoPathResult is FailureResult<String>) {
      return Result.failure(photoPathResult.failure);
    }

    return _repository.insert(
      Product(
        id: id,
        name: name,
        nameNormalized: normalized,
        notes: notes,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        uomLadder: uomLadder,
        photoPath: (photoPathResult as Success<String>).value,
      ),
    );
  }
}
