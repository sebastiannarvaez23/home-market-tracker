import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/formatters/date_formatter.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_tinted_icon.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_purchase_history_entry.dart';

class ProductPurchaseHistoryItem extends StatelessWidget {
  const ProductPurchaseHistoryItem({super.key, required this.entry});

  final ProductPurchaseHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      showChevron: false,
      leading: const AppTintedIcon(icon: AppIcons.store),
      title: AppText(
        entry.marketName,
        variant: AppTextVariant.title,
        maxLines: 1,
      ),
      subtitle: AppText(
        DateFormatter.dayMonthYear(entry.purchasedAt),
        variant: AppTextVariant.subtitle,
        maxLines: 1,
      ),
      trailing: AppPriceTag(price: entry.unitPrice),
    );
  }
}
