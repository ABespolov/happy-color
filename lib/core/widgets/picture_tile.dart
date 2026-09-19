import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/router.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';
import 'package:happy_color/features/progress/presentation/widgets/picture_actions_sheet.dart';

/// Decodes a card picture no larger than the cell it is shown in.
int pictureThumbnailWidth(BuildContext context) {
  final cell = MediaQuery.sizeOf(context).width / 2;
  return (cell * MediaQuery.devicePixelRatioOf(context)).round().clamp(
    200,
    512,
  );
}

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
              // A picture in progress shows the colors it has so far, a
              // finished one all of them, an untouched one its lines.
              child: switch (progress) {
                PictureProgress(isStarted: true, :final filled)
                    when !completed =>
                  ColoredPreview(assetDir: assetDir, filled: filled, size: 400),
                // The thumbnails keep a grid of cards from decoding pictures
                // many times the size of a cell.
                _ => Image.asset(
                  '$assetDir/'
                  '${completed ? 'artwork_thumb' : 'lines_thumb'}.webp',
                  cacheWidth: pictureThumbnailWidth(context),
                ),
              },
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
