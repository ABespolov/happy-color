import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/circle_icon_button.dart';

import 'package:happy_color/features/coloring/presentation/widgets/color_palette.dart';
import 'package:happy_color/features/coloring/presentation/controllers/coloring_controller.dart';
import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/painters/coloring_canvas_painter.dart';
import 'package:happy_color/features/coloring/presentation/painters/labels_painter.dart';
import 'package:happy_color/features/coloring/presentation/painters/line_art_painter.dart';

class ColoringView extends StatefulWidget {
  const ColoringView({
    super.key,
    required this.picture,
    required this.shader,
    required this.regionMap,
    required this.artwork,
    required this.lines,
    required this.filled,
    required this.onFilledChanged,
  });

  final ColoringPicture picture;
  final ui.FragmentShader shader;
  final ui.Image regionMap;
  final ui.Image artwork;
  final ui.Image lines;

  final Set<int> filled;

  final void Function(Set<int> filled) onFilledChanged;

  /// Fills the room around the picture, and the page behind it.
  static const canvasColor = Color(0xFFF2F2F2);

  @override
  State<ColoringView> createState() => _ColoringViewState();
}

class _ColoringViewState extends State<ColoringView>
    with TickerProviderStateMixin {
  late final _controller = ColoringController(
    picture: widget.picture,
    vsync: this,
    filled: widget.filled,
    onFilledChanged: widget.onFilledChanged,
  );
  final _transform = TransformationController();
  late final _labels = LabelAtlas(widget.picture.palette.length);

  late final _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  late final _fit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Animation<Matrix4>? _fitAnimation;

  bool get _zoomed => _transform.value != Matrix4.identity();

  void _fitToScreen() {
    _fitAnimation = Matrix4Tween(
      begin: _transform.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _fit, curve: Curves.easeOutCubic));
    _fit.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _fit.addListener(() {
      final animation = _fitAnimation;
      if (animation != null) _transform.value = animation.value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _transform.dispose();
    _labels.dispose();
    _fit.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picture = widget.picture;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final viewport = constraints.biggest;
                    final scale = math.min(
                      viewport.width / picture.size.width,
                      viewport.height / picture.size.height,
                    );
                    final fit = (
                      scale: scale,
                      offset: Offset(
                        (viewport.width - picture.size.width * scale) / 2,
                        (viewport.height - picture.size.height * scale) / 2,
                      ),
                      viewport: viewport,
                    );
                    return ColoredBox(
                      color: ColoringView.canvasColor,
                      child: InteractiveViewer(
                        transformationController: _transform,
                        maxScale: 12,
                        child: FittedBox(
                          child: SizedBox.fromSize(
                            size: picture.size,
                            child: GestureDetector(
                              onTapUp: (details) =>
                                  _controller.tapAt(details.localPosition),
                              child: ColoredBox(
                                color: Colors.white,
                                child: Stack(
                                  children: [
                                    _layer(
                                      ColoringCanvasPainter(
                                        controller: _controller,
                                        shader: widget.shader,
                                        regionMap: widget.regionMap,
                                        artwork: widget.artwork,
                                      ),
                                    ),
                                    _layer(LineArtPainter(widget.lines)),
                                    _layer(
                                      LabelsPainter(
                                        controller: _controller,
                                        transform: _transform,
                                        fit: fit,
                                        labels: _labels,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: CircleIconButton.back(context),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: ListenableBuilder(
                    listenable: _transform,
                    builder: (context, child) => AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _zoomed ? 1 : 0,
                      child: IgnorePointer(ignoring: !_zoomed, child: child),
                    ),
                    child: CircleIconButton(
                      icon: Icons.zoom_in_map,
                      iconSize: 24,
                      iconColor: AppColors.primary,
                      onTap: _fitToScreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _entrance,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: ColorPalette(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _layer(CustomPainter painter) => Positioned.fill(
    child: RepaintBoundary(child: CustomPaint(painter: painter)),
  );
}
