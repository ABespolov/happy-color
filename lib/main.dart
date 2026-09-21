import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/app/app.dart';
import 'package:happy_color/features/coloring/presentation/rendering/preview_store.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

/// Outlines every repaint in debug builds.
/// Run with `--dart-define=repaint_rainbow=true`.
const _repaintRainbow = bool.fromEnvironment('repaint_rainbow');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode && _repaintRainbow) debugRepaintRainbowEnabled = true;
  // Banners take about 20 MB and a category's thumbnails some 40 MB; less
  // than this drops one category's thumbnails while another is shown, and
  // they decode again, white first, on every switch back.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 160 << 20;

  // Waited for together: the native splash stays up until runApp.
  final (_, progress, previews) = await (
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    createProgressRepository(),
    createPreviewStore(),
  ).wait;
  runApp(
    ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(progress),
        previewStoreProvider.overrideWithValue(previews),
      ],
      child: const HappyColorApp(),
    ),
  );
}
