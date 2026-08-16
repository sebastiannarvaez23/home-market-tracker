import 'package:uuid/uuid.dart';

abstract class IdGenerator {
  String next();
}

class UuidGenerator implements IdGenerator {
  UuidGenerator();

  static const _uuid = Uuid();

  @override
  String next() => _uuid.v4();
}
