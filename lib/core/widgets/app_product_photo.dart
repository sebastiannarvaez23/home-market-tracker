import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/files/app_documents.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/widgets/app_gradient_icon.dart';

class AppProductPhoto extends StatefulWidget {
  const AppProductPhoto({
    super.key,
    this.path,
    this.size = 52,
  });

  final String? path;
  final double size;

  @override
  State<AppProductPhoto> createState() => _AppProductPhotoState();
}

class _AppProductPhotoState extends State<AppProductPhoto> {
  File? _file;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void didUpdateWidget(covariant AppProductPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _load();
    }
  }

  Future<void> _load() async {
    final path = widget.path?.trim();
    final file = path == null || path.isEmpty
        ? null
        : await AppDocuments.resolveFile(path);
    if (!mounted) return;
    setState(() {
      _file = file;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    if (file == null || _loading) {
      return AppGradientIcon.productFallback(size: widget.size);
    }
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) =>
            AppGradientIcon.productFallback(size: widget.size),
      ),
    );
  }
}
