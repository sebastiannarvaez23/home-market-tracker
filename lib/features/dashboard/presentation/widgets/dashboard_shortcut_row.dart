import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_card.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';
import 'package:home_market_tracker/core/widgets/app_tinted_icon.dart';

class DashboardShortcutRow extends StatelessWidget {
  const DashboardShortcutRow({
    super.key,
    required this.onOpenProducts,
    required this.onOpenHistory,
    required this.onOpenSuggestions,
  });

  final VoidCallback onOpenProducts;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenSuggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          AppStrings.dashboardShortcutsTitle,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ShortcutCard(
                icon: AppIcons.grocery,
                title: AppStrings.dashboardProductsShortcut,
                hint: AppStrings.dashboardProductsShortcutHint,
                onTap: onOpenProducts,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ShortcutCard(
                icon: AppIcons.history,
                title: AppStrings.dashboardHistoryShortcut,
                hint: AppStrings.dashboardHistoryShortcutHint,
                onTap: onOpenHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ShortcutCard(
          icon: AppIcons.insights,
          title: AppStrings.dashboardSuggestionsShortcut,
          hint: AppStrings.dashboardSuggestionsShortcutHint,
          onTap: onOpenSuggestions,
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTintedIcon(icon: icon, size: 44),
            const SizedBox(height: AppSpacing.sm),
            AppText(title, variant: AppTextVariant.title, maxLines: 1),
            const SizedBox(height: 4),
            AppText(
              hint,
              variant: AppTextVariant.caption,
              color: AppColors.textMuted,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
