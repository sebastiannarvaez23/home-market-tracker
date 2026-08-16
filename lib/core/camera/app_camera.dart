import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

abstract final class AppCamera {
  static final ImagePicker _picker = ImagePicker();

  /// Cámara en móvil. Si el plataforma no la soporta, elige un archivo.
  static Future<String?> captureProductPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 75,
        maxWidth: 1600,
      );
      return file?.path;
    } catch (_) {
      if (kIsWeb) return null;
      try {
        final file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
          maxWidth: 1600,
        );
        return file?.path;
      } catch (_) {
        return null;
      }
    }
  }
}
