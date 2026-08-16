import 'package:equatable/equatable.dart';

enum FailureCode {
  validation,
  notFound,
  conflict,
  precondition,
  inactive,
  storage,
}

class Failure extends Equatable {
  const Failure({required this.code, required this.message});

  const Failure.validation(String message)
      : this(code: FailureCode.validation, message: message);

  const Failure.notFound(String message)
      : this(code: FailureCode.notFound, message: message);

  const Failure.conflict(String message)
      : this(code: FailureCode.conflict, message: message);

  const Failure.precondition(String message)
      : this(code: FailureCode.precondition, message: message);

  const Failure.inactive(String message)
      : this(code: FailureCode.inactive, message: message);

  const Failure.storage(String message)
      : this(code: FailureCode.storage, message: message);

  final FailureCode code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
