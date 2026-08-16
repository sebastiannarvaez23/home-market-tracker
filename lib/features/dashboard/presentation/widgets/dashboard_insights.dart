import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/money_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_price_text.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_tinted_icon.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/dashboard_snapshot.dart';

class DashboardInsights extends StatelessWidget {
  const DashboardInsights({super.key, required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          AppStrings.dashboardMarketsTitle,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: snapshot.mostConvenientMarket == null &&
                  snapshot.highestSpendMarket == null
              ? const AppText(
                  AppStrings.dashboardNoMarketInsight,
                  variant: AppTextVariant.subtitle,
                  color: AppColors.textMuted,
                )
              : Column(
                  children: [
                    if (snapshot.mostConvenientMarket != null)
                      AppListTile(
                        showChevron: false,
                        leading: const AppTintedIcon(
                          icon: AppIcons.store,
                          backgroundColor: Color(0xFFE7FAF6),
                          iconColor: AppColors.tealDeep,
                        ),
                        title: const AppText(
                          AppStrings.dashboardConvenientMarket,
                          variant: AppTextVariant.caption,
                          color: AppColors.textMuted,
                        ),
                        subtitle: AppText(
                          snapshot.mostConvenientMarket!.marketName,
                          variant: AppTextVariant.title,
                          maxLines: 1,
                        ),
                        trailing: AppPriceTag(
                          price: snapshot.mostConvenientMarket!.total,
                        ),
                      ),
                    if (snapshot.highestSpendMarket != null)
                      AppListTile(
                        showChevron: false,
                        leading: const AppTintedIcon(icon: AppIcons.store),
                        title: const AppText(
                          AppStrings.dashboardHighestSpendMarket,
                          variant: AppTextVariant.caption,
                          color: AppColors.textMuted,
                        ),
                        subtitle: AppText(
                          snapshot.highestSpendMarket!.marketName,
                          variant: AppTextVariant.title,
                          maxLines: 1,
                        ),
                        trailing: AppPriceTag(
                          price: snapshot.highestSpendMarket!.total,
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppText(
          AppStrings.dashboardTopProductsTitle,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: snapshot.topProducts.isEmpty
              ? const AppText(
                  AppStrings.dashboardNoTopProducts,
                  variant: AppTextVariant.subtitle,
                  color: AppColors.textMuted,
                )
              : Column(
                  children: [
                    for (final product in snapshot.topProducts)
                      AppListTile(
                        showChevron: false,
                        leading: const AppTintedIcon(
                          icon: AppIcons.grocery,
                          backgroundColor: AppColors.purpleSoft,
                          iconColor: AppColors.purple,
                        ),
                        title: AppText(
                          product.productName,
                          variant: AppTextVariant.title,
                          maxLines: 1,
                        ),
                        trailing: AppPriceTag(price: product.total),
                      ),
                  ],
                ),
        ),
        if (snapshot.overprices.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const AppText(
            AppStrings.dashboardOverpricesTitle,
            variant: AppTextVariant.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                for (final alert in snapshot.overprices)
                  AppListTile(
                    showChevron: false,
                    leading: const AppTintedIcon(
                      icon: AppIcons.insights,
                      backgroundColor: Color(0xFFFFE8ED),
                      iconColor: AppColors.danger,
                    ),
                    title: AppText(
                      alert.productName,
                      variant: AppTextVariant.title,
                      maxLines: 1,
                    ),
                    subtitle: AppText(
                      AppStrings.paidVsBest(
                        MoneyFormatter.format(alert.paidPrice),
                        MoneyFormatter.format(alert.bestPrice),
                      ),
                      variant: AppTextVariant.caption,
                      color: AppColors.textMuted,
                      maxLines: 2,
                    ),
                    trailing: AppPriceText(
                      alert.difference,
                      color: AppColors.danger,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
