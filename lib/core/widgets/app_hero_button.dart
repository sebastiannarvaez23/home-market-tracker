import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppHeroButton extends StatelessWidget {
  const AppHeroButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.subtitle,
    this.gradient = AppColors.fireGradient,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? subtitle;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadii.lg + 4),
          boxShadow: AppShadows.fire,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(icon, color: AppColors.iconOnGradient, size: 30),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      label,
                      variant: AppTextVariant.title,
                      color: AppColors.iconOnGradient,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      AppText(
                        subtitle!,
                        variant: AppTextVariant.caption,
                        color: AppColors.iconOnGradient.withValues(alpha: 0.88),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
