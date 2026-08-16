import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

enum AppButtonVariant { primary, secondary, ghost, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = switch (variant) {
      AppButtonVariant.primary => AppColors.iconOnGradient,
      AppButtonVariant.secondary => AppColors.purple,
      AppButtonVariant.ghost || AppButtonVariant.outline =>
        AppColors.iconOnGradient,
    };
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: variant == AppButtonVariant.primary
                ? AppColors.tealGradient
                : null,
            color: switch (variant) {
              AppButtonVariant.secondary => AppColors.purpleSoft,
              AppButtonVariant.ghost => const Color(0x33FFFFFF),
              AppButtonVariant.outline || AppButtonVariant.primary => null,
            },
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: variant == AppButtonVariant.outline
                ? Border.all(color: const Color(0x88FFFFFF), width: 1.4)
                : null,
            boxShadow:
                variant == AppButtonVariant.primary ? AppShadows.soft : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
              ],
              AppText(
                label,
                variant: AppTextVariant.button,
                color: foreground,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
