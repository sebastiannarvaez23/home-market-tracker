import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_product_photo.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/products/domain/entities/product_with_last_purchase.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.item,
    this.onTap,
  });

  final ProductWithLastPurchase item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      onTap: onTap,
      leading: AppProductPhoto(
        key: ValueKey(item.product.id),
        path: item.product.photoPath,
      ),
      title: AppText(
        item.product.name,
        variant: AppTextVariant.title,
        maxLines: 1,
      ),
      subtitle: _subtitle(),
    );
  }

  Widget _subtitle() {
    final lastPurchase = item.lastPurchase;
    if (lastPurchase == null) {
      return const AppText(
        AppStrings.neverPurchased,
        variant: AppTextVariant.subtitle,
        maxLines: 1,
      );
    }
    return Row(
      children: [
        Flexible(child: AppTag.market(label: lastPurchase.marketName)),
        const SizedBox(width: 8),
        AppPriceTag(price: lastPurchase.unitPrice),
      ],
    );
  }
}
