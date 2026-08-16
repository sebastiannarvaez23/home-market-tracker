import 'package:equatable/equatable.dart';

class DashboardWindow extends Equatable {
  const DashboardWindow({
    required this.periodStart,
    required this.periodEndExclusive,
    required this.previousStart,
    required this.previousEndExclusive,
    required this.trendStart,
  });

  final DateTime periodStart;
  final DateTime periodEndExclusive;
  final DateTime previousStart;
  final DateTime previousEndExclusive;
  final DateTime trendStart;

  int get periodStartMs => periodStart.millisecondsSinceEpoch;
  int get periodEndExclusiveMs => periodEndExclusive.millisecondsSinceEpoch;
  int get previousStartMs => previousStart.millisecondsSinceEpoch;
  int get previousEndExclusiveMs => previousEndExclusive.millisecondsSinceEpoch;
  int get trendStartMs => trendStart.millisecondsSinceEpoch;

  factory DashboardWindow.fromAnchor(DateTime anchor) {
    final periodStart = DateTime(anchor.year, anchor.month, 1);
    final periodEnd = DateTime(anchor.year, anchor.month + 1, 1);
    final previousStart = DateTime(periodStart.year, periodStart.month - 1, 1);
    final trendStart = DateTime(periodStart.year, periodStart.month - 5, 1);
    return DashboardWindow(
      periodStart: periodStart,
      periodEndExclusive: periodEnd,
      previousStart: previousStart,
      previousEndExclusive: periodStart,
      trendStart: trendStart,
    );
  }

  @override
  List<Object?> get props => [
        periodStart,
        periodEndExclusive,
        previousStart,
        previousEndExclusive,
        trendStart,
      ];
}
