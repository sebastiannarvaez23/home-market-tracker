import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 3),
    );
  }
}
