import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/picture_tile.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

/// Warms up what the first screens show, so they do not appear empty and then
/// fill in. Only the first cards of a grid are worth warming: the rest are
/// loaded by the time the user scrolls to them.
class Startup {
  const Startup(this.ref);

  final Ref ref;

  /// How long the splash screen may wait for all of this.
  static const timeout = Duration(seconds: 2);

  static const _cards = 6;

  Future<void> warmUp(BuildContext context) async {
    final width = MediaQuery.sizeOf(context).width;
    final pixels = MediaQuery.devicePixelRatioOf(context);
    await Future.wait([
      _banners(context, (width * pixels).round()),
      _cardPictures(context),
    ]).timeout(timeout, onTimeout: () => const []);
  }

  /// Library opens on its banners, and they are the largest images around.
  Future<void> _banners(BuildContext context, int width) async {
    final banners = await ref.read(libraryBannersProvider.future);
    if (!context.mounted) return;
    await Future.wait([
      for (final banner in banners)
        if (banner.imageAsset case final asset?)
          precacheImage(ResizeImage(AssetImage(asset), width: width), context),
    ]);
  }

  /// The first cards of the library, and the previews of whatever the user was
  /// coloring last time.
  Future<void> _cardPictures(BuildContext context) async {
    final pictures = await ref.read(libraryPicturesProvider('all').future);
    final progress = await ref.read(progressProvider.future);
    final cache = ref.read(previewCacheProvider);
    if (!context.mounted) return;
    final thumbnailWidth = pictureThumbnailWidth(context);
    await Future.wait([
      for (final picture in pictures.take(_cards))
        if (!(progress[picture.id]?.isStarted ?? false))
          precacheImage(
            ResizeImage(
              AssetImage('${picture.assetDir}/lines_thumb.webp'),
              width: thumbnailWidth,
            ),
            context,
          ),
      for (final started
          in progress.values.where((p) => p.isStarted).take(_cards))
        coloredPreview(
          cache,
          assetDir: started.assetDir,
          size: ColoredPreview.cardSize,
          filled: started.filled,
        ),
    ]);
  }
}

final startupProvider = Provider<Startup>(Startup.new);
