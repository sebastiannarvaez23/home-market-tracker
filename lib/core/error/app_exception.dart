class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});
}

class PreconditionException extends AppException {
  const PreconditionException(super.message, {super.cause});
}

class ConflictException extends AppException {
  const ConflictException(super.message, {super.cause});
}

class InactiveException extends AppException {
  const InactiveException(super.message, {super.cause});
}
