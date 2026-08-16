import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/constants/app_strings.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_button.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppError extends StatelessWidget {
  const AppError({
    super.key,
    this.message = AppStrings.errorLoadProducts,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.error, size: 48, color: AppColors.danger),
            const SizedBox(height: AppSpacing.md),
            AppText(
              message,
              variant: AppTextVariant.body,
              color: AppColors.textMuted,
              align: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: AppStrings.retry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
