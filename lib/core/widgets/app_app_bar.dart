import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_icon_button.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.onSearch,
    this.onAction,
    this.actionIcon,
    this.showBack = true,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final bool showBack;
  final Widget? trailing;

  static const _toolbarHeight = 76.0;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      clipBehavior: Clip.none,
      centerTitle: true,
      toolbarHeight: _toolbarHeight,
      titleSpacing: 0,
      leadingWidth: showBack ? 84 : 0,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, 8, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppIconButton(
                  icon: AppIcons.back,
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
            )
          : null,
      title: AppText(title, variant: AppTextVariant.title),
      actions: [
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, AppSpacing.md, 14),
            child: Center(child: trailing),
          ),
        if (onAction != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, AppSpacing.md, 14),
            child: AppIconButton(
              icon: actionIcon ?? AppIcons.edit,
              onPressed: onAction,
            ),
          ),
        if (onSearch != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, AppSpacing.md, 14),
            child: AppIconButton(
              icon: AppIcons.search,
              onPressed: onSearch,
            ),
          ),
      ],
    );
  }
}
