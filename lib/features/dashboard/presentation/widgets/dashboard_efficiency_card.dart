import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/percent_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_floating_surface.dart';
import 'package:home_market_tracker/core/widgets/app_price_text.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardEfficiencyCard extends StatelessWidget {
  const DashboardEfficiencyCard({super.key, required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final efficiency = snapshot.efficiency;
    return AppFloatingSurface(
      gradient: AppColors.purpleGradient,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            AppStrings.dashboardEfficiencyTitle,
            variant: AppTextVariant.caption,
            color: AppColors.iconOnGradient,
          ),
          const SizedBox(height: 8),
          AppText(
            efficiency == null
                ? AppStrings.dashboardNotAvailable
                : PercentFormatter.whole(efficiency.value),
            variant: AppTextVariant.display,
            color: AppColors.iconOnGradient,
          ),
          const SizedBox(height: 6),
          AppText(
            _bandMessage(efficiency?.band),
            variant: AppTextVariant.subtitle,
            color: AppColors.iconOnGradient.withValues(alpha: 0.86),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: AppText(
                  AppStrings.dashboardSavingsLabel,
                  variant: AppTextVariant.caption,
                  color: AppColors.iconOnGradient,
                ),
              ),
              AppPriceText(
                snapshot.potentialSavings,
                variant: AppTextVariant.title,
                color: AppColors.iconOnGradient,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _bandMessage(EfficiencyBand? band) {
    return switch (band) {
      EfficiencyBand.high => AppStrings.dashboardEfficiencyHigh,
      EfficiencyBand.medium => AppStrings.dashboardEfficiencyMedium,
      EfficiencyBand.low => AppStrings.dashboardEfficiencyLow,
      null => AppStrings.dashboardEfficiencyEmpty,
    };
  }
}
