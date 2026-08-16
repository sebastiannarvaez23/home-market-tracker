import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract final class AppDocuments {
  static Future<String>? _cachedPath;

  static Future<String> path() {
    return _cachedPath ??=
        getApplicationDocumentsDirectory().then((directory) => directory.path);
  }

  static Future<File?> resolveFile(String? storedPath) async {
    final value = storedPath?.trim();
    if (value == null || value.isEmpty) return null;
    final direct = File(value);
    if (await direct.exists()) return direct;
    final joined = File(p.join(await path(), value));
    if (await joined.exists()) return joined;
    return null;
  }
}
