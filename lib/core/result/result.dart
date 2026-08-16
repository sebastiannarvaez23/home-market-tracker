import 'package:home_market_tracker/core/error/failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  Failure? get failureOrNull => switch (this) {
        FailureResult(:final failure) => failure,
        Success() => null,
      };

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        FailureResult() => null,
      };

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(:final value) => Result.success(transform(value)),
      FailureResult(:final failure) => Result.failure(failure),
    };
  }

  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T value) transform,
  ) {
    return switch (this) {
      Success(:final value) => transform(value),
      FailureResult(:final failure) => Future.value(Result.failure(failure)),
    };
  }

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      FailureResult(failure: final f) => failure(f),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
