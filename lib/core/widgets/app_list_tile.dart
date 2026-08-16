import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.showChevron = true,
    this.trailing,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron)
            const Icon(
              AppIcons.chevronRight,
              color: AppColors.textMuted,
              size: 22,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
