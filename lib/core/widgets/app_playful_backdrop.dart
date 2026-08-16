import 'package:flutter/widgets.dart';

class AppPlayfulBackdrop extends StatelessWidget {
  const AppPlayfulBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: -40,
          right: -30,
          child: _Blob(color: Color(0x33FF8A65), size: 140),
        ),
        const Positioned(
          top: 120,
          left: -50,
          child: _Blob(color: Color(0x332EE0C5), size: 120),
        ),
        const Positioned(
          bottom: 80,
          right: -20,
          child: _Blob(color: Color(0x338E54E9), size: 100),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}
