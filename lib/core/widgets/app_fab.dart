import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/widgets/app_floating_surface.dart';

class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AppFloatingSurface(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        shadows: AppShadows.floating,
        child: const Icon(
          AppIcons.add,
          color: AppColors.iconOnGradient,
          size: 30,
        ),
      ),
    );
  }
}
