import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/router.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';
import 'package:happy_color/features/progress/presentation/widgets/picture_actions_sheet.dart';

/// A picture in a grid: opens it for coloring, stars it on a long press and
/// shows how far it is colored.
class PictureTile extends ConsumerWidget {
  const PictureTile({super.key, required this.id, required this.assetDir});

  final String id;
  final String assetDir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider).value?[id];
    final completed = progress?.isCompleted ?? false;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // A picture with colors in it asks what to do with them first.
        onTap: () => switch (progress) {
          PictureProgress(isStarted: true) && final started =>
            PictureActionsSheet.show(context, started),
          _ => context.push(Routes.picture(id, assetDir)),
        },
        onLongPress: () =>
            ref.read(progressProvider.notifier).toggleStarred(id, assetDir),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              // A finished picture shows its colors, an unfinished one its lines.
              child: Image.asset(
                '$assetDir/${completed ? 'artwork.webp' : 'lines.webp'}',
              ),
            ),
            if (progress case PictureProgress(isStarted: true, :final fraction)
                when !completed)
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: _ProgressBar(fraction: fraction),
              ),
            if (progress?.starred ?? false)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.star_rounded, color: Color(0xFFFFC107)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 6,
        backgroundColor: AppColors.placeholder.withValues(alpha: 0.25),
      ),
    );
  }
}
