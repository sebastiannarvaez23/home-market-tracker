import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';

abstract final class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const chip = [
    BoxShadow(
      color: Color(0x338E54E9),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const iconButton = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const floating = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x338E54E9),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const overlay = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 40,
      offset: Offset(0, -12),
    ),
    BoxShadow(
      color: Color(0x3D8E54E9),
      blurRadius: 32,
      offset: Offset(0, -4),
    ),
  ];

  static const fire = [
    BoxShadow(
      color: Color(0x59FF6B35),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static Color get glow => AppColors.purple.withValues(alpha: 0.18);
}
