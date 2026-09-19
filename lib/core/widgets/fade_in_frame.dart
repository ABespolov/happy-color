import 'package:flutter/material.dart';

/// A `frameBuilder` for [Image]: a picture that is still decoding eases in
/// once it arrives, growing slightly as it fades, while one the image cache
/// already has is drawn as it is, so a grid seen before comes back without a
/// flicker.
Widget fadeInFrame(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  return _Appear(shown: frame != null, child: child);
}

class _Appear extends StatefulWidget {
  const _Appear({required this.shown, required this.child});

  final bool shown;
  final Widget child;

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: widget.shown ? 1 : 0,
  );

  late final _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  /// The picture settles into place from just under its final size, slowing
  /// down as it arrives, with no overshoot.
  late final _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

  @override
  void didUpdateWidget(_Appear old) {
    super.didUpdateWidget(old);
    if (widget.shown && !old.shown) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
