import 'package:flutter/material.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/animation_math.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/hopping_dot.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/tab_icon_stage.dart';

class MoreTabIcon extends StatelessWidget {
  const MoreTabIcon({super.key, required this.progress});

  final Animation<double> progress;

  static const _dots = ['more/dot_yellow', 'more/dot_red', 'more/dot_blue'];

  @override
  Widget build(BuildContext context) {
    return TabIconStage(
      progress: progress,
      shadowWidth: 64,
      shadowY: 86,
      builder: (t) => Stack(
        children: [
          for (final (i, dot) in _dots.indexed)
            HoppingDot(
              layer: dot,
              t: interval(t, 0.08 + i * 0.1, 0.6 + i * 0.1, Curves.easeInOut),
            ),
        ],
      ),
    );
  }
}
