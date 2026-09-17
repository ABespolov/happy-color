import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';

/// Shared choreography for tab icons: anticipation squash, jump and landing.
/// Draws on a 96×96 canvas scaled to the available size.
class TabIconStage extends StatelessWidget {
  const TabIconStage({
    super.key,
    required this.progress,
    required this.builder,
    required this.shadowWidth,
    required this.shadowY,
  });

  final Animation<double> progress;
  final Widget Function(double t) builder;
  final double shadowWidth;
  final double shadowY;

  static final _scaleX = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.06,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 15,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.06,
        end: 0.97,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.97,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
  ]);
  static final _scaleY = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.92,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 15,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.92,
        end: 1.04,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.04,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
  ]);
  static final _jump = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 15),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 7.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 7.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 35,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
  ]);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        final jump = _jump.transform(t);
        return FittedBox(
          child: SizedBox.square(
            dimension: 96,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 48 - shadowWidth / 2,
                  top: shadowY - 4,
                  child: Transform.scale(
                    scale: 1 - jump / 7 * 0.2,
                    child: Container(
                      width: shadowWidth,
                      height: 8,
                      decoration: const ShapeDecoration(
                        shape: OvalBorder(),
                        color: AppColors.iconShadow,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -jump),
                  child: Transform(
                    alignment: const Alignment(0, 0.75),
                    transform: Matrix4.diagonal3Values(
                      _scaleX.transform(t),
                      _scaleY.transform(t),
                      1,
                    ),
                    child: builder(t),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
