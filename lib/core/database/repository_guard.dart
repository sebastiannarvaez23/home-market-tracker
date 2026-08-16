import 'package:home_market_tracker/core/error/app_exception.dart';
import 'package:home_market_tracker/core/error/failure.dart';
import 'package:home_market_tracker/core/result/result.dart';
import 'package:sqflite/sqflite.dart';

abstract final class RepositoryGuard {
  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on NotFoundException catch (error) {
      return Result.failure(Failure.notFound(error.message));
    } on PreconditionException catch (error) {
      return Result.failure(Failure.precondition(error.message));
    } on InactiveException catch (error) {
      return Result.failure(Failure.inactive(error.message));
    } on ConflictException catch (error) {
      return Result.failure(Failure.conflict(error.message));
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        return const Result.failure(
          Failure.conflict('Ya existe un registro con ese identificador.'),
        );
      }
      return Result.failure(Failure.storage(error.toString()));
    } on AppException catch (error) {
      return Result.failure(Failure.storage(error.message));
    } catch (error) {
      return Result.failure(Failure.storage(error.toString()));
    }
  }
}
