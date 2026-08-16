import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/core/formatters/money_formatter.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/value/money.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

class AppPriceText extends StatelessWidget {
  const AppPriceText(
    this.money, {
    super.key,
    this.variant = AppTextVariant.caption,
    this.color = AppColors.purple,
  });

  final Money money;
  final AppTextVariant variant;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppText(
      MoneyFormatter.format(money),
      variant: variant,
      color: color,
      maxLines: 1,
    );
  }
}
