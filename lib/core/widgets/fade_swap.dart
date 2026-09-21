import 'package:flutter/material.dart';

/// Eases [child] in. A child with another key comes in only after the old
/// one has faded out, so the two are never drawn over each other.
class FadeSwap extends StatefulWidget {
  const FadeSwap({super.key, required this.child});

  final Widget child;

  @override
  State<FadeSwap> createState() => _FadeSwapState();
}

class _FadeSwapState extends State<FadeSwap>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    reverseDuration: const Duration(milliseconds: 120),
  )..forward();

  late final _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeIn,
  );

  late final _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

  late Widget _shown = widget.child;

  Widget? _next;
  var _swapping = false;

  @override
  void didUpdateWidget(FadeSwap old) {
    super.didUpdateWidget(old);
    if (widget.child.key == _shown.key) {
      _shown = widget.child;
      _next = null;
      return;
    }
    _next = widget.child;
    if (!_swapping) _swap();
  }

  Future<void> _swap() async {
    _swapping = true;
    await _controller.reverse();
    if (!mounted) return;
    // A newer child may have arrived while this one was fading out.
    final next = _next;
    if (next != null) {
      setState(() => _shown = next);
      _next = null;
    }
    await _controller.forward();
    if (!mounted) return;
    _swapping = false;
    if (_next != null) _swap();
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
      child: ScaleTransition(scale: _scale, child: _shown),
    );
  }
}
