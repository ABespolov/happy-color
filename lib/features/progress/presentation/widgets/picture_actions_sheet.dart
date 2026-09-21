import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/router.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/route_settled.dart';
import 'package:happy_color/features/coloring/presentation/providers/coloring_scene.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// What to do with a picture that is already partly colored.
class PictureActionsSheet extends ConsumerStatefulWidget {
  const PictureActionsSheet({super.key, required this.progress});

  final PictureProgress progress;

  static Future<void> show(BuildContext context, PictureProgress progress) =>
      showModalBottomSheet<void>(
        context: context,
        // Covers the shell's tab bar.
        useRootNavigator: true,
        backgroundColor: AppColors.tabBar,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (_) => PictureActionsSheet(progress: progress),
      );

  @override
  ConsumerState<PictureActionsSheet> createState() =>
      _PictureActionsSheetState();
}

class _PictureActionsSheetState extends ConsumerState<PictureActionsSheet> {
  PictureProgress get progress => widget.progress;

  var _warming = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_warming) {
      _warming = true;
      unawaited(_warmScene());
    }
  }

  /// Every action opens the picture. Its textures decode once the sheet is
  /// up, not while it slides in.
  Future<void> _warmScene() async {
    await routeSettled(context);
    if (mounted) ref.read(coloringSceneLoaderProvider).warm(progress.assetDir);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.close, color: AppColors.ink),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: ColoredPreview(
                assetDir: progress.assetDir,
                filled: progress.filled,
              ),
            ),
            const SizedBox(height: 16),
            _Action(
              icon: Icons.play_arrow_outlined,
              label: l10n.continueColoring,
              onTap: () => _open(context),
            ),
            const Divider(height: 1),
            _Action(
              icon: Icons.refresh,
              label: l10n.colorAgain,
              onTap: () {
                ref.read(progressProvider.notifier).clear(progress.id);
                _open(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).pop();
    context.push(Routes.picture(progress.id, progress.assetDir));
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink),
            const SizedBox(width: 18),
            Text(
              label,
              style: const TextStyle(fontSize: 20, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
