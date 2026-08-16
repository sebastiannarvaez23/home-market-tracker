import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/formatters/date_formatter.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_tinted_icon.dart';
import 'package:home_market_tracker/features/history/domain/entities/history_entry.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({
    super.key,
    required this.entry,
    this.onTap,
  });

  final HistoryEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      onTap: onTap,
      leading: const AppTintedIcon(icon: AppIcons.store),
      title: AppText(
        entry.marketNameSnapshot,
        variant: AppTextVariant.title,
        maxLines: 1,
      ),
      subtitle: AppText(
        '${DateFormatter.dayMonthYear(entry.completedAt)}  ·  ${AppStrings.itemCountLabel(entry.itemCount)}',
        variant: AppTextVariant.subtitle,
        maxLines: 1,
      ),
      trailing: AppPriceTag(price: entry.total),
    );
  }
}
