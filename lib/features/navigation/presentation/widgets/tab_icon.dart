import 'package:flutter/material.dart';

/// A tab icon that squashes, hops and settles back every time its tab is
/// tapped. One image, one animation.
class TabIcon extends StatelessWidget {
  const TabIcon({
    super.key,
    required this.asset,
    required this.progress,
    required this.selected,
  });

  final String asset;
  final Animation<double> progress;

  /// An unselected icon steps back a little and loses some of its color.
  final bool selected;

  static const _hop = 6.0;

  static final _squash = TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.88).chain(_ease(Curves.easeOut)),
      weight: 20,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.88, end: 1.0).chain(_ease(Curves.elasticOut)),
      weight: 80,
    ),
  ]);

  static final _jump = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: _hop).chain(_ease(Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(begin: _hop, end: 0.0).chain(_ease(Curves.bounceOut)),
      weight: 50,
    ),
  ]);

  static Animatable<double> _ease(Curve curve) => CurveTween(curve: curve);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -_jump.transform(progress.value)),
        child: Transform.scale(
          scale: _squash.transform(progress.value),
          child: child,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: selected ? 1 : 0.55,
        child: Image.asset(asset),
      ),
    );
  }
}
