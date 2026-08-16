import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFBFBFE);
  static const surface = Color(0xFFFFFFFF);
  static const purple = Color(0xFF8E54E9);
  static const purpleDeep = Color(0xFF6C3CD9);
  static const purpleSoft = Color(0xFFF1ECFB);
  static const teal = Color(0xFF2EE0C5);
  static const tealDeep = Color(0xFF1BC4B0);
  static const textPrimary = Color(0xFF2C2740);
  static const textMuted = Color(0xFF9B97AB);
  static const chipIdle = Color(0xFFF3F0FA);
  static const danger = Color(0xFFE85D75);
  static const iconOnGradient = Color(0xFFFFFFFF);

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B4DFF), Color(0xFFB07CFF)],
  );

  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2EE0C5), Color(0xFF7CFFB2)],
  );

  static const orangeGlyph = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A65), Color(0xFFFFC27A)],
  );

  static const tealGlyph = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF26C6DA), Color(0xFF80DEEA)],
  );

  static const pinkGlyph = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7EB3), Color(0xFFFFC2D7)],
  );

  static const fireGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFFC857)],
  );

  static const purpleGlyph = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
  );
}
