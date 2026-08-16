import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';

class AppFloatingSurface extends StatelessWidget {
  const AppFloatingSurface({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.borderRadius,
    this.shadows,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.lg),
        boxShadow: shadows ?? AppShadows.floating,
      ),
      child: child,
    );
  }
}
