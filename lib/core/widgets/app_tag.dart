import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/widgets/app_price_text.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/value/money.dart';

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.purpleSoft,
    this.foregroundColor = AppColors.purple,
  });

  const AppTag.market({super.key, required this.label})
      : backgroundColor = AppColors.purpleSoft,
        foregroundColor = AppColors.purple;

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: foregroundColor,
        maxLines: 1,
      ),
    );
  }
}

class AppPriceTag extends StatelessWidget {
  const AppPriceTag({super.key, required this.price});

  final Money price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FAF6),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: AppPriceText(
        price,
        variant: AppTextVariant.caption,
        color: AppColors.tealDeep,
      ),
    );
  }
}
