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
  /// Warmed up by the sheet that opened this page, when there was one.
  late final _scene = ref
      .read(coloringSceneLoaderProvider)
      .take(widget.assetDir);

  /// Kept in a field: `ref` cannot be read once the page is being disposed of.
  late final PreviewCache _previews = ref.read(previewCacheProvider);

  /// What was colored when the page last saved, used to build the card-sized
  /// preview the grid will need.
  Set<int> _lastSaved = const {};

  void _warmCardPreview() {
    if (_lastSaved.isEmpty) return;
    coloredPreview(
      _previews,
      assetDir: widget.assetDir,
      size: ColoredPreview.cardSize,
      filled: _lastSaved,
    ).ignore();
  }

  @override
  void dispose() {
    _warmCardPreview();
    _scene.then((scene) => scene.dispose());
    super.dispose();
  }

  /// Read once: the view keeps the colored regions itself from then on.
  late final _filled = ref
      .read(progressProvider.notifier)
      .of(widget.id, widget.assetDir)
      .filled;

  void _saveFilled(Set<int> filled) {
    _lastSaved = filled;
    ref
        .read(progressProvider.notifier)
        .setFilled(
          widget.id,
          widget.assetDir,
          filled: filled,
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
          // The picture is already on screen as a preview while the shader and
          // the textures load, so there is nothing to wait in front of. The
          // view is faded in over it once its first frame, the one that
          // compiles the shader, is out of the way.
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

  /// Whether the coloring view has fully covered the preview it opened on.
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
    // The same layout the coloring view has, so the picture does not jump
    // when the preview gives way to it.
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
