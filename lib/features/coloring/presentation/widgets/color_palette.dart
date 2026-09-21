import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:happy_color/features/coloring/presentation/controllers/coloring_controller.dart';

class ColorPalette extends StatefulWidget {
  const ColorPalette({super.key, required this.controller});

  final ColoringController controller;

  static const _height = 84.0;

  /// Height of the palette with the room it keeps under the colors.
  static double heightOf(BuildContext context) =>
      _height + _bottomInset(context);

  static const _item = 60.0;
  static const _gap = 12.0;
  static const _padding = 16.0;

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.selectedColor.addListener(_showSelected);
  }

  @override
  void dispose() {
    widget.controller.selectedColor.removeListener(_showSelected);
    _scroll.dispose();
    super.dispose();
  }

  /// When a color is done, the one picked next is often off the edge.
  void _showSelected() {
    if (!_scroll.hasClients) return;
    final i = widget.controller.selectedColor.value;
    const step = ColorPalette._item + ColorPalette._gap;
    final start = ColorPalette._padding + i * step;
    final end = start + ColorPalette._item;
    final viewport = _scroll.position.viewportDimension;
    final offset = _scroll.offset;
    final target = switch (0) {
      _ when start - step < offset => start - step,
      _ when end + step > offset + viewport => end + step - viewport,
      _ => offset,
    };
    _scroll.animateTo(
      target.clamp(0.0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final palette = controller.picture.palette;
    return Material(
      elevation: 8,
      child: SizedBox(
        height: ColorPalette.heightOf(context),
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.selectedColor,
            controller.fills,
          ]),
          builder: (context, _) => ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(
              ColorPalette._padding,
              12,
              ColorPalette._padding,
              12 + _bottomInset(context),
            ),
            itemCount: palette.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: ColorPalette._gap),
            itemBuilder: (context, i) {
              final progress = controller.progress(i);
              return _PaletteItem(
                key: ValueKey(i),
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

/// A gesture bar's inset is capped; a navigation bar with buttons needs all
/// of its inset, or the colors end up against the buttons.
double _bottomInset(BuildContext context) {
  final inset = MediaQuery.viewPaddingOf(context).bottom;
  return (inset > 36 ? inset : inset.clamp(8.0, 34.0)) + 8;
}

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({
    super.key,
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

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final foreground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.1 : 1,
        duration: _duration,
        curve: _curve,
        child: SizedBox.square(
          dimension: ColorPalette._item,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: _duration,
                  curve: _curve,
                  builder: (context, progress, _) =>
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: selected ? 1.0 : 0.0),
                        duration: _duration,
                        curve: _curve,
                        builder: (context, picked, _) =>
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: lerpDouble(4, 6, picked)!,
                              backgroundColor: Colors.black12,
                              color: Color.lerp(
                                Colors.black38,
                                Colors.black87,
                                picked,
                              ),
                            ),
                      ),
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
                child: AnimatedSwitcher(
                  duration: _duration,
                  switchInCurve: _curve,
                  switchOutCurve: _curve,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: progress >= 1
                      ? Icon(
                          Icons.check,
                          key: const ValueKey('done'),
                          color: foreground,
                        )
                      : Text(
                          '$number',
                          key: const ValueKey('number'),
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
