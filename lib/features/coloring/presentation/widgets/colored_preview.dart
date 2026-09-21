import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/fade_in_frame.dart';
import 'package:happy_color/core/widgets/picture_thumbnail.dart';
import 'package:happy_color/core/widgets/route_settled.dart';
import 'package:happy_color/features/coloring/presentation/rendering/preview_renderer.dart'
    as renderer;
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';

/// Shows a picture the way the user left it.
class ColoredPreview extends ConsumerStatefulWidget {
  const ColoredPreview({
    super.key,
    required this.assetDir,
    required this.filled,
    this.size = 1000,
  });

  final String assetDir;
  final Set<int> filled;

  final int size;

  static const thumbnailSize = renderer.thumbnailSize;
  static const cardSize = 400;

  @override
  ConsumerState<ColoredPreview> createState() => _ColoredPreviewState();
}

class _ColoredPreviewState extends ConsumerState<ColoredPreview> {
  /// `ref` cannot be read while the widget is disposed of.
  late final PreviewCache _cache = ref.read(previewCacheProvider);

  /// This widget's own handle; stays up until a newer preview replaces it.
  ui.Image? _image;

  /// Requests are numbered so a slow render never replaces a newer one.
  var _requested = 0;
  var _shown = 0;

  Timer? _pending;

  /// Renders wait for a sheet or a page to finish coming in.
  Future<void>? _routeSettled;

  /// Set while the card is out of sight (under the coloring page, in another
  /// tab) and its preview is out of date: it renders once it shows again
  /// instead of once per tap.
  var _stale = true;

  PreviewKey get _key => PreviewKey(
    assetDir: widget.assetDir,
    size: widget.size,
    filled: widget.filled,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeSettled ??= routeSettled(context);
    if (_stale && TickerMode.valuesOf(context).enabled) {
      _stale = false;
      _request();
    }
  }

  @override
  void didUpdateWidget(ColoredPreview old) {
    super.didUpdateWidget(old);
    if (old.assetDir == widget.assetDir &&
        old.size == widget.size &&
        setEquals(old.filled, widget.filled)) {
      return;
    }
    _pending?.cancel();
    if (!TickerMode.valuesOf(context).enabled) {
      _stale = true;
      return;
    }
    // Only the last of a burst of taps is worth rendering.
    _pending = Timer(
      const Duration(milliseconds: 150),
      () => setState(_request),
    );
  }

  @override
  void dispose() {
    _pending?.cancel();
    _image?.dispose();
    super.dispose();
  }

  void _request() {
    final key = _key;
    final id = ++_requested;
    if (_cache.ready(key) case final image?) {
      _show(id, image);
      return;
    }
    // A sheet or a page opens on the card's preview scaled up, not blank.
    if (_image == null) {
      if (_cache.readyAtOtherSize(key) case final image?) _show(id, image);
    }
    unawaited(_render(id, key));
  }

  Future<void> _render(int id, PreviewKey key) async {
    await _routeSettled;
    final ui.Image image;
    try {
      image = await _cache.preview(key);
    } on Object {
      return;
    }
    if (!mounted || id < _shown) return image.dispose();
    setState(() => _show(id, image));
  }

  void _show(int id, ui.Image image) {
    _image?.dispose();
    _image = image;
    _shown = id;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    // The colors fade in over the line art rather than an empty square.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      child: image == null
          ? Image.asset(
              '${widget.assetDir}/lines_thumb.webp',
              key: const ValueKey('lines'),
              cacheWidth: pictureThumbnailWidth(context),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              frameBuilder: fadeInFrame,
            )
          : _OwnImage(key: ObjectKey(image), image: image),
    );
  }
}

/// Paints a clone of [image] of its own, so the preview can let go of [image]
/// while this one is still fading out.
class _OwnImage extends StatefulWidget {
  const _OwnImage({super.key, required this.image});

  final ui.Image image;

  @override
  State<_OwnImage> createState() => _OwnImageState();
}

class _OwnImageState extends State<_OwnImage> {
  late final ui.Image _image = widget.image.clone();

  @override
  void dispose() {
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RawImage(image: _image, fit: BoxFit.contain);
}
