import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/app/app.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await createProgressRepository();
  runApp(
    ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(progress)],
      child: const HappyColorApp(),
    ),
  );
}
