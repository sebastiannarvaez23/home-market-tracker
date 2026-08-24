import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_photo_viewer.dart';
import 'package:home_market_tracker/core/widgets/app_tag.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/features/products/domain/entities/product.dart';

class ProductDetailHeader extends StatelessWidget {
  const ProductDetailHeader({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPhotoBanner(
          path: product.photoPath,
          heroTag: 'product-photo-${product.id}',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            0,
          ),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  product.name,
                  variant: AppTextVariant.display,
                  maxLines: 2,
                ),
                if (product.notes != null && product.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  AppText(
                    product.notes!,
                    variant: AppTextVariant.subtitle,
                    color: AppColors.textMuted,
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    AppTag(label: product.uomLadder.base.code),
                    for (final step in product.uomLadder.steps)
                      AppTag(label: product.uomLadder.labelOf(step)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
