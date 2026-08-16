abstract final class DateFormatter {
  static const _monthsShort = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  static String dayMonthYear(int epochMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String monthShort(DateTime date) => _monthsShort[date.month - 1];

  static String monthYear(DateTime date) {
    return '${monthShort(date)} ${date.year}';
  }
}
