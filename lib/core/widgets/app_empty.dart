import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.empty, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            AppText(
              message,
              variant: AppTextVariant.body,
              color: AppColors.textMuted,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
