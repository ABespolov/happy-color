import 'package:flutter/material.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/popping_tool.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/svg_layer.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/tab_icon_stage.dart';

class MyFeedTabIcon extends StatelessWidget {
  const MyFeedTabIcon({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return TabIconStage(
      progress: progress,
      shadowWidth: 52,
      shadowY: 88,
      builder: (t) => Stack(
        children: [
          PoppingTool(
            layer: 'my_feed/pencil',
            t: t,
            start: 0.08,
            pivot: const Offset(36, 72),
            tilt: -1,
          ),
          PoppingTool(
            layer: 'my_feed/brush_blue',
            t: t,
            start: 0.22,
            pivot: const Offset(61, 72),
            tilt: 1,
          ),
          PoppingTool(
            layer: 'my_feed/brush_red',
            t: t,
            start: 0.15,
            pivot: const Offset(48, 72),
            tilt: -1,
          ),
          const SvgLayer('my_feed/cup'),
        ],
      ),
    );
  }
}
