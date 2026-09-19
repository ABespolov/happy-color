import 'package:flutter/material.dart';

/// A `frameBuilder` for [Image]: a picture that is still decoding eases in
/// once it arrives, while one the image cache already has is drawn as it is.
Widget fadeInFrame(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  return Appear(shown: frame != null, child: child);
}

/// Eases its child in, growing slightly as it fades, once [shown] is true.
class Appear extends StatefulWidget {
  const Appear({super.key, this.shown = true, required this.child});

  final bool shown;
  final Widget child;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

  @override
  void initState() {
    super.initState();
    if (widget.shown) _controller.forward();
  }

  @override
  void didUpdateWidget(Appear old) {
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
