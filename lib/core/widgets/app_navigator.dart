import 'package:flutter/material.dart';

abstract final class AppNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(builder: (_) => page),
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }
}
