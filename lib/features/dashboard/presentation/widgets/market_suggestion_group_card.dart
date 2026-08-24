import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_tinted_icon.dart';
import 'package:home_market_tracker/features/dashboard/domain/entities/market_suggestion.dart';

class MarketSuggestionGroupCard extends StatelessWidget {
  const MarketSuggestionGroupCard({super.key, required this.group});

  final MarketSuggestionGroup group;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppTintedIcon(
                icon: AppIcons.store,
                backgroundColor: Color(0xFFE7FAF6),
                iconColor: AppColors.tealDeep,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  group.marketName,
                  variant: AppTextVariant.title,
                  maxLines: 1,
                ),
              ),
              AppTag(label: AppStrings.itemCountLabel(group.items.length)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppText(
            AppStrings.marketSuggestionsBestPriceHint,
            variant: AppTextVariant.caption,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in group.items)
            AppListTile(
              showChevron: false,
              leading: const AppTintedIcon(
                icon: AppIcons.grocery,
                backgroundColor: AppColors.purpleSoft,
                iconColor: AppColors.purple,
              ),
              title: AppText(
                item.productName,
                variant: AppTextVariant.title,
                maxLines: 1,
              ),
              subtitle: AppText(
                item.uom.code,
                variant: AppTextVariant.caption,
                color: AppColors.textMuted,
              ),
              trailing: AppPriceTag(price: item.unitPrice),
            ),
        ],
      ),
    );
  }
}
