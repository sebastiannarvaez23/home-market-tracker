import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:home_market_tracker/core/utils/name_normalizer.dart';

abstract final class CatalogValidator {
  static const int nameMaxLength = 80;
  static const int notesMaxLength = 280;
  static const int locationMaxLength = 120;

  static Result<String> name(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(
        Failure.validation('El nombre es obligatorio.'),
      );
    }
    if (trimmed.length > nameMaxLength) {
      return const Result.failure(
        Failure.validation('El nombre no puede superar 80 caracteres.'),
      );
    }
    return Result.success(trimmed);
  }

  static String normalizedName(String name) => NameNormalizer.normalize(name);

  static Result<String?> notes(String? raw) {
    if (raw == null) return const Result.success(null);
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const Result.success(null);
    if (trimmed.length > notesMaxLength) {
      return const Result.failure(
        Failure.validation('Las notas no pueden superar 280 caracteres.'),
      );
    }
    return Result.success(trimmed);
  }

  static Result<String> photoSourcePath(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) {
      return const Result.failure(
        Failure.validation('La foto del producto es obligatoria.'),
      );
    }
    return Result.success(trimmed);
  }

  static Result<String?> location(String? raw) {
    if (raw == null) return const Result.success(null);
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const Result.success(null);
    if (trimmed.length > locationMaxLength) {
      return const Result.failure(
        Failure.validation('La ubicación no puede superar 120 caracteres.'),
      );
    }
    return Result.success(trimmed);
  }
}
