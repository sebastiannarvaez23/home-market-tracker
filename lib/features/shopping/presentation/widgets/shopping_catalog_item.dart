import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/widgets/app_add_button.dart';
import 'package:home_market_tracker/core/widgets/app_product_photo.dart';
import 'package:home_market_tracker/core/widgets/app_list_tile.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_catalog_refs.dart';
import 'package:home_market_tracker/features/shopping/domain/entities/shopping_item.dart';

class ShoppingCatalogItem extends StatelessWidget {
  const ShoppingCatalogItem({
    super.key,
    required this.product,
    required this.onAdd,
    this.item,
  });

  final ShoppingProductRef product;
  final ShoppingItem? item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      showChevron: false,
      leading: AppProductPhoto(
        key: ValueKey(product.id),
        path: product.photoPath,
      ),
      title: AppText(
        product.name,
        variant: AppTextVariant.title,
        maxLines: 1,
      ),
      subtitle: item == null ? null : AppPriceTag(price: item!.unitPrice),
      trailing: AppAddButton(added: item != null, onPressed: onAdd),
    );
  }
}
