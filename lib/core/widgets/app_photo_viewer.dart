import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/files/app_documents.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/theme/app_spacing.dart';
import 'package:home_market_tracker/core/widgets/app_icon_button.dart';
import 'package:home_market_tracker/core/widgets/app_loading.dart';
import 'package:home_market_tracker/core/widgets/app_navigator.dart';
import 'package:home_market_tracker/core/widgets/app_product_photo.dart';

class AppPhotoBanner extends StatelessWidget {
  const AppPhotoBanner({
    super.key,
    required this.path,
    this.heroTag,
    this.aspectRatio = 16 / 9,
  });

  final String? path;
  final Object? heroTag;
  final double aspectRatio;

  bool get _canOpen {
    final value = path?.trim();
    return value != null && value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final canOpen = _canOpen;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: AppProductPhoto(
        path: path,
        width: double.infinity,
        height: double.infinity,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
        heroTag: canOpen ? heroTag : null,
        showExpandHint: canOpen,
        onTap: canOpen
            ? () => AppPhotoViewer.show(
                  context,
                  path: path!.trim(),
                  heroTag: heroTag,
                )
            : null,
      ),
    );
  }
}

abstract final class AppPhotoViewer {
  static Future<void> show(
    BuildContext context, {
    required String path,
    Object? heroTag,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, __) => _AppPhotoViewerPage(
          path: path,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _AppPhotoViewerPage extends StatefulWidget {
  const _AppPhotoViewerPage({
    required this.path,
    this.heroTag,
  });

  final String path;
  final Object? heroTag;

  @override
  State<_AppPhotoViewerPage> createState() => _AppPhotoViewerPageState();
}

class _AppPhotoViewerPageState extends State<_AppPhotoViewerPage> {
  File? _file;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    final file = await AppDocuments.resolveFile(widget.path);
    if (!mounted) return;
    setState(() {
      _file = file;
      _loading = false;
    });
  }

  void _close() => AppNavigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final file = _file;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _loading
                ? const AppLoading()
                : file == null
                    ? const SizedBox.shrink()
                    : InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: SizedBox.expand(
                          child: _image(file),
                        ),
                      ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            left: AppSpacing.md,
            child: AppIconButton(
              icon: AppIcons.close,
              onPressed: _close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(File file) {
    final image = Image.file(
      file,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
    if (widget.heroTag == null) return image;
    return Hero(tag: widget.heroTag!, child: image);
  }
}
