import 'package:flutter/material.dart';

import 'package:happy_color/features/coloring/presentation/controllers/coloring_controller.dart';

class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key, required this.controller});

  final ColoringController controller;

  static const _height = 84.0;

  /// Height of the palette with the room it keeps under the colors.
  static double heightOf(BuildContext context) =>
      _height + _bottomInset(context);

  @override
  Widget build(BuildContext context) {
    final palette = controller.picture.palette;
    return Material(
      elevation: 8,
      child: SizedBox(
        height: heightOf(context),
        child: ListenableBuilder(
          listenable: Listenable.merge([controller.selectedColor, controller]),
          builder: (context, _) => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + _bottomInset(context),
            ),
            itemCount: palette.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final progress = controller.progress(i);
              return _PaletteItem(
                color: palette[i],
                number: i + 1,
                progress: progress,
                selected: controller.selectedColor.value == i,
                onTap: progress < 1
                    ? () => controller.selectedColor.value = i
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Room under the colors, so they never touch the edge of the screen even
/// where the system leaves no inset.
double _bottomInset(BuildContext context) =>
    MediaQuery.viewPaddingOf(context).bottom.clamp(8.0, 34.0) + 8;

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({
    required this.color,
    required this.number,
    required this.progress,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final int number;
  final double progress;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: selected ? 6 : 4,
                backgroundColor: Colors.black12,
                color: selected ? Colors.black87 : Colors.black38,
              ),
            ),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
              child: progress >= 1
                  ? Icon(Icons.check, color: foreground)
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
