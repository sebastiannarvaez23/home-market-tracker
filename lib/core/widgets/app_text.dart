import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';

enum AppTextVariant { display, title, body, subtitle, caption, button, chip }

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.body,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
      style: _style.copyWith(color: color ?? _defaultColor),
    );
  }

  Color get _defaultColor {
    return switch (variant) {
      AppTextVariant.subtitle || AppTextVariant.caption => AppColors.textMuted,
      _ => AppColors.textPrimary,
    };
  }

  TextStyle get _style {
    return switch (variant) {
      AppTextVariant.display => GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      AppTextVariant.title => GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      AppTextVariant.body => GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      AppTextVariant.subtitle => GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
      AppTextVariant.caption => GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      AppTextVariant.button => GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      AppTextVariant.chip => GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
    };
  }
}
