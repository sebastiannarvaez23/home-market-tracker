import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppTrendBar {
  const AppTrendBar({required this.label, required this.value});

  final String label;
  final double value;
}

class AppTrendChart extends StatelessWidget {
  const AppTrendChart({super.key, required this.bars});

  final List<AppTrendBar> bars;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxValue = bars.fold<double>(0, (max, bar) {
      return bar.value > max ? bar.value : max;
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < bars.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Bar(bar: bars[i], maxValue: maxValue)),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.bar, required this.maxValue});

  final AppTrendBar bar;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue <= 0 ? 0.0 : (bar.value / maxValue).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 88,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction == 0 ? 0.08 : fraction,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: fraction == 0 ? null : AppColors.purpleGradient,
                  color: fraction == 0 ? AppColors.chipIdle : null,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppText(
          bar.label,
          variant: AppTextVariant.caption,
          color: AppColors.textMuted,
          maxLines: 1,
        ),
      ],
    );
  }
}
