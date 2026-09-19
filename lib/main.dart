import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/app/app.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
