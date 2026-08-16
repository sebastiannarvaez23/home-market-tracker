import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/camera/app_camera.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/widgets/app_product_photo.dart';

class AppPhotoCapture extends StatelessWidget {
  const AppPhotoCapture({
    super.key,
    required this.imagePath,
    required this.onCaptured,
    this.size = 72,
  });

  final String? imagePath;
  final ValueChanged<String> onCaptured;
  final double size;

  Future<void> _capture() async {
    final path = await AppCamera.captureProductPhoto();
    if (path != null) {
      onCaptured(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imagePath != null && imagePath!.trim().isNotEmpty;
    return GestureDetector(
      onTap: _capture,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (hasPhoto)
            AppProductPhoto(
              path: imagePath,
              size: size,
            )
          else
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGlyph,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orangeGlyph.colors.last.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                AppIcons.camera,
                color: AppColors.iconOnGradient,
                size: size * 0.42,
              ),
            ),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.camera,
              size: 16,
              color: hasPhoto ? AppColors.purple : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
