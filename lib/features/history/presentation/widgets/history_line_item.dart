import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_tinted_icon.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_line.dart';

class HistoryLineItem extends StatelessWidget {
  const HistoryLineItem({super.key, required this.line});

  final HistoryLine line;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      showChevron: false,
      leading: const AppTintedIcon(icon: AppIcons.grocery),
      title: AppText(
        line.productNameSnapshot,
        variant: AppTextVariant.title,
        maxLines: 1,
      ),
      subtitle: AppText(
        AppStrings.quantityWithUom(line.quantity.compact, line.uom.code),
        variant: AppTextVariant.subtitle,
        color: AppColors.textMuted,
        maxLines: 1,
      ),
      trailing: AppPriceTag(price: line.lineTotal),
    );
  }
}
