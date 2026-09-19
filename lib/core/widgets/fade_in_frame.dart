import 'package:flutter/material.dart';

/// A `frameBuilder` for [Image]: a picture that is still decoding eases in
/// once it arrives, while one the image cache already has is drawn as it
/// is. Used inside an [Appear], which plays the same motion for the card
/// itself, so a late picture does not pop into a card that has settled.
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
/// Plays every time the widget is created, whether or not what it shows
/// was ready already, so cards come in the same way whatever the cache
/// holds.
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

  /// The picture settles into place from just under its final size, slowing
  /// down as it arrives, with no overshoot.
  late final _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

  var _started = false;

  /// The animation starts the first time the widget is both shown and in
  /// sight. A card in a tab that is not on screen has its tickers muted: an
  /// animation started there would count the time it spent muted and be
  /// over the moment the tab slides in, so the card would just pop up.
  void _startIfSeen() {
    if (_started || !widget.shown) return;
    if (!TickerMode.valuesOf(context).enabled) return;
    _started = true;
    _controller.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startIfSeen();
  }

  @override
  void didUpdateWidget(Appear old) {
    super.didUpdateWidget(old);
    _startIfSeen();
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
