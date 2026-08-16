import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';

class AppGradientIcon extends StatelessWidget {
  const AppGradientIcon({
    super.key,
    required this.gradient,
    required this.icon,
    this.size = 52,
  });

  factory AppGradientIcon.product({required int seed, double size = 52}) {
    final looks = _productLooks[seed.abs() % _productLooks.length];
    return AppGradientIcon(gradient: looks.gradient, icon: looks.icon, size: size);
  }

  factory AppGradientIcon.productFallback({double size = 52}) {
    return AppGradientIcon(
      gradient: AppColors.purpleGlyph,
      icon: AppIcons.grocery,
      size: size,
    );
  }

  factory AppGradientIcon.market({required int seed, double size = 52}) {
    final looks = _marketLooks[seed.abs() % _marketLooks.length];
    return AppGradientIcon(gradient: looks.gradient, icon: looks.icon, size: size);
  }

  factory AppGradientIcon.fire({double size = 72}) {
    return AppGradientIcon(
      gradient: AppColors.fireGradient,
      icon: AppIcons.fire,
      size: size,
    );
  }

  final LinearGradient gradient;
  final IconData icon;
  final double size;

  static const _productLooks = [
    (gradient: AppColors.orangeGlyph, icon: AppIcons.grocery),
    (gradient: AppColors.tealGlyph, icon: AppIcons.nutrition),
    (gradient: AppColors.pinkGlyph, icon: AppIcons.cafe),
    (gradient: AppColors.purpleGlyph, icon: AppIcons.bakery),
  ];

  static const _marketLooks = [
    (gradient: AppColors.tealGlyph, icon: AppIcons.store),
    (gradient: AppColors.orangeGlyph, icon: AppIcons.grocery),
    (gradient: AppColors.pinkGlyph, icon: AppIcons.cart),
    (gradient: AppColors.purpleGlyph, icon: AppIcons.nutrition),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.iconOnGradient, size: size * 0.48),
    );
  }
}
