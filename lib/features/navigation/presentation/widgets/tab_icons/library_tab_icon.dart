import 'package:flutter/material.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/animation_math.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/flipping_page.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/svg_layer.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/tab_icon_stage.dart';

class LibraryTabIcon extends StatelessWidget {
  const LibraryTabIcon({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return TabIconStage(
      progress: progress,
      shadowWidth: 68,
      shadowY: 86,
      builder: (t) => Stack(
        children: [
          const SvgLayer('library/base'),
          FlippingPage(t: interval(t, 0.1, 0.65, Curves.easeInOut)),
          FlippingPage(t: interval(t, 0.25, 0.8, Curves.easeInOut)),
        ],
      ),
    );
  }
}
