import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

import 'package:happy_color/features/coloring/presentation/providers/coloring_scene.dart';
import 'package:happy_color/features/coloring/presentation/widgets/color_palette.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';
import 'package:happy_color/features/coloring/presentation/widgets/coloring_view.dart';
import 'package:happy_color/l10n/app_localizations.dart';

class ColoringPage extends ConsumerStatefulWidget {
  const ColoringPage({super.key, required this.id, required this.assetDir});

  final String id;

  /// Folder with the files written by `tools/generate_picture.py`.
  final String assetDir;

  @override
  ConsumerState<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends ConsumerState<ColoringPage> {
  late final _scene = ref
      .read(coloringSceneLoaderProvider)
      .take(widget.assetDir);

  /// `ref` cannot be read in [dispose], where the card preview is warmed up.
  late final PreviewCache _previews;

  @override
  void initState() {
    super.initState();
    _previews = ref.read(previewCacheProvider);
  }

  /// What was colored at the last save.
  Set<int> _lastSaved = const {};

  void _warmCardPreview() {
    if (_lastSaved.isEmpty) return;
    _previews
        .warm(
          PreviewKey(
            assetDir: widget.assetDir,
            size: ColoredPreview.cardSize,
            filled: _lastSaved,
          ),
        )
        .ignore();
  }

  @override
  void dispose() {
    if (_save != null) _flush();
    _warmCardPreview();
    unawaited(ColoringScene.disposeLoaded(_scene));
    super.dispose();
  }

  late final _filled = ref
      .read(progressProvider.notifier)
      .of(widget.id, widget.assetDir)
      .filled;

  /// `ref` cannot be read in [dispose], where the last save happens.
  ProgressNotifier? _progress;

  Timer? _save;

  Set<int>? _pendingFilled;

  /// Fills come every few hundred milliseconds, and each save encodes the
  /// whole progress on the UI thread, so saves are batched.
  void _saveFilled(Set<int> filled) {
    _progress ??= ref.read(progressProvider.notifier);
    _pendingFilled = filled;
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 400), _flush);
  }

  void _flush() {
    _save?.cancel();
    _save = null;
    // The controller's set is live.
    _lastSaved = Set.of(_pendingFilled!);
    _progress?.setFilled(
      widget.id,
      widget.assetDir,
      filled: _lastSaved,
      regionCount: _regionCount,
    );
  }

  var _regionCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoringView.canvasColor,
      body: FutureBuilder(
        future: _scene,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!
                    .loadingFailed('${snapshot.error}'),
              ),
            );
          }
          final scene = snapshot.data;
          if (scene != null) _regionCount = scene.picture.regions.length;
          // The preview shows the picture while the scene loads; the view
          // fades in over it after its first frame compiles the shader.
          return Stack(
            fit: StackFit.expand,
            children: [
              if (!_revealed)
                _Loading(assetDir: widget.assetDir, filled: _filled),
              if (scene != null)
                _Reveal(
                  onRevealed: () => setState(() => _revealed = true),
                  child: ColoringView(
                    picture: scene.picture,
                    shader: scene.shader,
                    regionMap: scene.regionMap,
                    artwork: scene.artwork,
                    lines: scene.lines,
                    filled: _filled,
                    onFilledChanged: _saveFilled,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  var _revealed = false;
}

/// Fades its child in, starting only after the child has drawn a frame: a
/// fade that starts on the same frame as a shader compile would jump.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.onRevealed, required this.child});

  final VoidCallback onRevealed;
  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await _controller.forward();
      if (mounted) widget.onRevealed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: widget.child,
    );
  }
}

/// The picture as it was left, shown while the coloring scene loads.
class _Loading extends StatelessWidget {
  const _Loading({required this.assetDir, required this.filled});

  final String assetDir;
  final Set<int> filled;

  @override
  Widget build(BuildContext context) {
    // The coloring view's layout, so the picture does not jump.
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: ColoredPreview(
                  assetDir: assetDir,
                  filled: filled,
                  size: ColoredPreview.thumbnailSize,
                ),
              ),
            ),
          ),
          SizedBox(height: ColorPalette.heightOf(context)),
        ],
      ),
    );
  }
}
