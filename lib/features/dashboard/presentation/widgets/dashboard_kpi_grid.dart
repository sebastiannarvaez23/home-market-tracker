import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/percent_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_price_text.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardKpiGrid extends StatelessWidget {
  const DashboardKpiGrid({super.key, required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: AppStrings.dashboardSpendLabel,
                child: AppPriceText(
                  snapshot.periodSpend,
                  variant: AppTextVariant.title,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: AppStrings.dashboardVariationLabel,
                child: AppText(
                  _variationLabel(),
                  variant: AppTextVariant.title,
                  color: _variationColor(),
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: AppStrings.dashboardPurchasesLabel,
                child: AppText(
                  '${snapshot.purchaseCount}',
                  variant: AppTextVariant.title,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: AppStrings.dashboardTicketLabel,
                child: snapshot.averageTicket == null
                    ? const AppText(
                        AppStrings.dashboardNotAvailable,
                        variant: AppTextVariant.title,
                      )
                    : AppPriceText(
                        snapshot.averageTicket!,
                        variant: AppTextVariant.title,
                        color: AppColors.textPrimary,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _variationLabel() {
    final variation = snapshot.variation;
    if (!variation.hasComparisonBase) {
      return AppStrings.dashboardNoComparison;
    }
    return PercentFormatter.signed(variation.percent ?? 0);
  }

  Color _variationColor() {
    final variation = snapshot.variation;
    if (!variation.hasComparisonBase) {
      return AppColors.textMuted;
    }
    final percent = variation.percent ?? 0;
    if (percent > 0) return AppColors.danger;
    if (percent < 0) return AppColors.tealDeep;
    return AppColors.textPrimary;
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: AppTextVariant.caption,
            color: AppColors.textMuted,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
