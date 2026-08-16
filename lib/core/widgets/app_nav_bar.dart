import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          10,
          AppSpacing.md,
          10 + bottom,
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavButton(
                  item: items[i],
                  selected: i == currentIndex,
                  onPressed: () => onChanged(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purple : AppColors.textMuted;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.purpleSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Icon(item.icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          AppText(
            item.label,
            variant: AppTextVariant.caption,
            color: color,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
