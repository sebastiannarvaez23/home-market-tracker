import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppUrgencyDivider extends StatelessWidget {
  const AppUrgencyDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: label == null
          ? const _UrgencyLine()
          : Row(
              children: [
                const Expanded(child: _UrgencyLine()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: AppText(
                    label!,
                    variant: AppTextVariant.chip,
                    color: AppColors.danger,
                    maxLines: 1,
                  ),
                ),
                const Expanded(child: _UrgencyLine()),
              ],
            ),
    );
  }
}

class _UrgencyLine extends StatelessWidget {
  const _UrgencyLine();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55E85D75),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const SizedBox(height: 3, width: double.infinity),
    );
  }
}
