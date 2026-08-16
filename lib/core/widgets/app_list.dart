import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';

class AppList<T> extends StatelessWidget {
  const AppList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.separatorHeight = AppSpacing.xs,
    this.separatorBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double separatorHeight;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return this.separatorBuilder?.call(context, index) ??
            SizedBox(height: separatorHeight);
      },
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
    );
  }
}
