import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/fade_in_frame.dart';
import 'package:happy_color/core/widgets/picture_thumbnail.dart';
import 'package:happy_color/core/widgets/route_settled.dart';
import 'package:happy_color/features/coloring/presentation/rendering/preview_store.dart';

/// Shows a picture the way the user left it.
class ColoredPreview extends ConsumerStatefulWidget {
  const ColoredPreview({
    super.key,
    required this.assetDir,
    required this.filled,
    this.cacheWidth,
  });

  final String assetDir;
  final Set<int> filled;

  /// Pixels to decode the preview at; the width of the screen by default.
  final int? cacheWidth;

  @override
  ConsumerState<ColoredPreview> createState() => _ColoredPreviewState();
}

class _ColoredPreviewState extends ConsumerState<ColoredPreview> {
  late final PreviewStore _store = ref.read(previewStoreProvider);

  /// The file shown; an out-of-date one stays up while the new one renders.
  File? _file;

  /// Renders are numbered so a slow one never replaces a newer one.
  var _requested = 0;

  Timer? _pending;

  /// Set while the card is out of sight (under the coloring page, in another
  /// tab) and its preview is out of date: it renders once it shows again
  /// instead of once per tap.
  var _stale = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stale && TickerMode.valuesOf(context).enabled) {
      _stale = false;
      _update();
    }
  }

  @override
  void didUpdateWidget(ColoredPreview old) {
    super.didUpdateWidget(old);
    if (old.assetDir == widget.assetDir &&
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
      () => setState(_update),
    );
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  void _update() {
    if (_store.saved(widget.assetDir, widget.filled) case final file?) {
      _file = file;
      _requested++;
      return;
    }
    _file ??= _store.latest(widget.assetDir);
    unawaited(_render(++_requested, widget.assetDir, widget.filled));
  }

  Future<void> _render(int id, String assetDir, Set<int> filled) async {
    await routeSettled(context);
    if (!mounted || id != _requested) return;
    final File file;
    try {
      file = await _store.save(assetDir, filled);
    } on Object {
      return;
    }
    if (mounted && id == _requested) setState(() => _file = file);
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    final card = pictureThumbnailWidth(context);
    final width = widget.cacheWidth ?? _screenWidth(context);
    // The colors fade in over the line art rather than an empty square.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      child: file == null
          ? Image.asset(
              '${widget.assetDir}/lines_thumb.webp',
              key: const ValueKey('lines'),
              cacheWidth: card,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              frameBuilder: fadeInFrame,
            )
          : Image.file(
              file,
              key: const ValueKey('preview'),
              cacheWidth: width,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              // A sheet or a page opens on the card's copy, scaled up, until
              // its own size is decoded.
              frameBuilder: (context, child, frame, synchronous) =>
                  frame != null || width <= card
                  ? child
                  : Image.file(
                      file,
                      cacheWidth: card,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
            ),
    );
  }

  static int _screenWidth(BuildContext context) =>
      (MediaQuery.sizeOf(context).width *
              MediaQuery.devicePixelRatioOf(context))
          .round()
          .clamp(1, PreviewStore.size);
}
