import 'package:flutter/widgets.dart';
import 'package:home_market_tracker/app/app.dart';
import 'package:home_market_tracker/app/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const HomeMarketTrackerApp());
}
