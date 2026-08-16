import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';

class AppTintedIcon extends StatelessWidget {
  const AppTintedIcon({
    super.key,
    required this.icon,
    this.size = 48,
    this.backgroundColor = AppColors.purpleSoft,
    this.iconColor = AppColors.purple,
  });

  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
