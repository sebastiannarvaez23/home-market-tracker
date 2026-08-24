import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:home_market_tracker/core/files/app_documents.dart';
import 'package:home_market_tracker/core/theme/app_colors.dart';
import 'package:home_market_tracker/core/theme/app_icons.dart';
import 'package:home_market_tracker/core/theme/app_radii.dart';
import 'package:home_market_tracker/core/widgets/app_gradient_icon.dart';

class AppProductPhoto extends StatefulWidget {
  const AppProductPhoto({
    super.key,
    this.path,
    this.size = 52,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.showExpandHint = false,
  });

  final String? path;
  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Object? heroTag;
  final VoidCallback? onTap;
  final bool showExpandHint;

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
    if (widget.width == null && widget.height == null) {
      return _frame(width: widget.size, height: widget.size);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolve(widget.width, constraints.maxWidth, widget.size);
        final height =
            _resolve(widget.height, constraints.maxHeight, widget.size);
        return _frame(width: width, height: height);
      },
    );
  }

  double _resolve(double? value, double max, double fallback) {
    if (value == null) return fallback;
    if (value.isInfinite) return max;
    return value;
  }

  Widget _frame({required double width, required double height}) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppRadii.md);
    final file = _file;
    final isSquareThumbnail = widget.width == null && widget.height == null;
    if ((file == null || _loading) && isSquareThumbnail) {
      return AppGradientIcon.productFallback(size: height);
    }
    final image = file == null || _loading
        ? _placeholder(width: width, height: height, radius: radius)
        : Image.file(
            file,
            fit: widget.fit,
            width: width,
            height: height,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _placeholder(
              width: width,
              height: height,
              radius: radius,
            ),
          );
    final tagged = widget.heroTag == null
        ? image
        : Hero(tag: widget.heroTag!, child: image);
    final photo = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          tagged,
          if (widget.showExpandHint && widget.onTap != null)
            const _ExpandHint(),
        ],
      ),
    );
    if (widget.onTap == null) return photo;
    return GestureDetector(
      onTap: widget.onTap,
      child: photo,
    );
  }

  Widget _placeholder({
    required double width,
    required double height,
    required BorderRadius radius,
  }) {
    final isSquare = (width - height).abs() < 0.5 && width.isFinite;
    if (isSquare) {
      return AppGradientIcon.productFallback(size: height);
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGlyph,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Icon(
        AppIcons.grocery,
        color: AppColors.iconOnGradient,
        size: math.min(width.isFinite ? width : height, height) * 0.32,
      ),
    );
  }
}

class _ExpandHint extends StatelessWidget {
  const _ExpandHint();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x73000000),
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
          ),
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              AppIcons.expandPhoto,
              color: AppColors.iconOnGradient,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
