import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_shadows.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_floating_surface.dart';
import 'package:home_market_tracker/core/widgets/app_text.dart';

abstract final class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.none,
      barrierColor: const Color(0x59000000),
      builder: (_) => child,
    );
  }

  static void close<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }
}

class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    super.key,
    required this.glyph,
    required this.title,
    required this.body,
    required this.actions,
    this.trailing,
  });

  final Widget glyph;
  final String title;
  final Widget body;
  final Widget actions;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(top: 24, bottom: bottomInset),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          AppFloatingSurface(
            margin: const EdgeInsets.only(top: 36),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              48,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            gradient: AppColors.purpleGradient,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.lg + 10),
            ),
            shadows: AppShadows.overlay,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.82,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: trailing == null ? 0 : 48,
                            ),
                            child: AppText(
                              title,
                              variant: AppTextVariant.title,
                              color: AppColors.iconOnGradient,
                              align: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                          if (trailing != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: trailing,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    body,
                    const SizedBox(height: AppSpacing.lg),
                    actions,
                  ],
                ),
              ),
            ),
          ),
          glyph,
        ],
      ),
    );
  }
}
