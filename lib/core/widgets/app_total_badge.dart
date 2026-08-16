import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/widgets/app_price_text.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppTotalBadge extends StatelessWidget {
  const AppTotalBadge({super.key, required this.total});

  final Money total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.fire,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: AppPriceText(
          total,
          variant: AppTextVariant.button,
          color: AppColors.iconOnGradient,
        ),
      ),
    );
  }
}
