import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/app/app.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

/// Outlines every repaint in a changing color, to see what is being redrawn
/// while scrolling. Debug builds only: the drawing is stripped out of profile
/// and release builds, where frame times are measured in DevTools instead.
/// Run with `--dart-define=repaint_rainbow=true`.
const _repaintRainbow = bool.fromEnvironment('repaint_rainbow');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode && _repaintRainbow) debugRepaintRainbowEnabled = true;
  // Draw under the status and navigation bars. This is the default when the
  // app targets a recent Android, and a no-op before Android 10.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Two caches share the memory: this one holds assets decoded through an
  // ImageProvider, the preview cache holds the pictures the app paints itself.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 64 << 20;

  final progress = await createProgressRepository();
  runApp(
    ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(progress)],
      child: const HappyColorApp(),
    ),
  );
}
