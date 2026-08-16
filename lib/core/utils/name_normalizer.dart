abstract final class NameNormalizer {
  static String normalize(String raw) {
    return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
