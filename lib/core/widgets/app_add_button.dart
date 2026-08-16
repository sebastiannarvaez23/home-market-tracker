import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';

class AppAddButton extends StatelessWidget {
  const AppAddButton({
    super.key,
    required this.onPressed,
    this.added = false,
  });

  final VoidCallback onPressed;
  final bool added;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: added ? AppColors.tealGradient : AppColors.fireGradient,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: added ? AppShadows.soft : AppShadows.fire,
        ),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            added ? AppIcons.check : AppIcons.add,
            color: AppColors.iconOnGradient,
            size: 24,
          ),
        ),
      ),
    );
  }
}
