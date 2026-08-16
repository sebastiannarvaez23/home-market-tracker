abstract final class PercentFormatter {
  static String signed(double value) {
    final rounded = value.round();
    if (rounded > 0) {
      return '+$rounded%';
    }
    return '$rounded%';
  }

  static String whole(double value) => '${value.round()}';
}
