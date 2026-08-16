import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/date_formatter.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_trend_chart.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardTrendCard extends StatelessWidget {
  const DashboardTrendCard({super.key, required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          AppStrings.dashboardTrendTitle,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: AppTrendChart(
            bars: [
              for (final month in snapshot.trend)
                AppTrendBar(
                  label: DateFormatter.monthShort(month.monthStart),
                  value: month.total.amount,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
