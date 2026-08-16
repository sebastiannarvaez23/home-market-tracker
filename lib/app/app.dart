import 'package:flutter/material.dart';
import 'package:home_market_tracker/app/home_shell.dart';
import 'package:home_market_tracker/core/theme/app_theme.dart';

class HomeMarketTrackerApp extends StatelessWidget {
  const HomeMarketTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercadito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeShell(),
    );
  }
}
