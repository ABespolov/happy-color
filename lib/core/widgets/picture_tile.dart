import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/fade_in_frame.dart';
import 'package:happy_color/core/widgets/fade_swap.dart';
import 'package:happy_color/core/widgets/picture_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/router.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';
import 'package:happy_color/features/progress/presentation/widgets/picture_actions_sheet.dart';

/// A picture in a grid.
class PictureTile extends ConsumerWidget {
  const PictureTile({super.key, required this.id, required this.assetDir});

  final String id;
  final String assetDir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Coloring one picture does not rebuild every card.
    final progress = ref.watch(
      progressProvider.select((progress) => progress.value?[id]),
    );
    final completed = progress?.isCompleted ?? false;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => switch (progress) {
          PictureProgress(isStarted: true) && final started =>
            PictureActionsSheet.show(context, started),
          _ => context.push(Routes.picture(id, assetDir)),
        },
        onLongPress: () =>
            ref.read(progressProvider.notifier).toggleStarred(id, assetDir),
        child: FadeSwap(
          child: Stack(
            key: ValueKey(id),
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: switch (progress) {
                  PictureProgress(isStarted: true, :final filled)
                      when !completed =>
                    ColoredPreview(
                      assetDir: assetDir,
                      filled: filled,
                      size: 400,
                    ),
                  _ => Image.asset(
                    '$assetDir/'
                    '${completed ? 'artwork_thumb' : 'lines_thumb'}.webp',
                    cacheWidth: pictureThumbnailWidth(context),
                    gaplessPlayback: true,
                    frameBuilder: fadeInFrame,
                  ),
                },
              ),
              if (progress
                  case PictureProgress(isStarted: true, :final fraction)
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
