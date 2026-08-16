import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.purpleGradient : null,
          color: selected ? null : AppColors.chipIdle,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: selected ? AppShadows.chip : null,
        ),
        child: AppText(
          label,
          variant: AppTextVariant.chip,
          color: selected ? AppColors.iconOnGradient : AppColors.textMuted,
        ),
      ),
    );
  }
}

class AppChipBar extends StatelessWidget {
  const AppChipBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}
