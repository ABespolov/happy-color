import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/picture_tile.dart';
import 'package:happy_color/features/coloring/presentation/providers/coloring_scene.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/banner_card.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

/// Warms up what the first screens show, so they do not appear empty and then
/// fill in. Only the first cards of a grid are worth warming: the rest are
/// loaded by the time the user scrolls to them.
class Startup {
  const Startup(this.ref);

  final Ref ref;

  /// How long the splash screen may wait for [warmUp].
  static const timeout = Duration(seconds: 2);

  static const _cards = 6;

  /// What the app opens on: the feed of pictures being colored. The splash
  /// screen waits for this and nothing else.
  Future<void> warmUp(BuildContext context) =>
      _feed(context).timeout(timeout, onTimeout: () {});

  /// What the screens after that show: the library and the coloring page.
  /// Runs behind the feed once it is up.
  Future<void> warmUpBehind(BuildContext context) async {
    // The shader is read from the bundle once; the coloring page finds it
    // ready.
    ref.read(coloringSceneLoaderProvider).program.ignore();
    await Future.wait([
      _banners(context, BannerCard.cacheWidth(context)),
      _libraryCards(context),
    ]);
  }

  /// The previews of the pictures being colored, or the illustration of the
  /// empty feed when there are none.
  Future<void> _feed(BuildContext context) async {
    final progress = await ref.read(progressProvider.future);
    if (!context.mounted) return;
    final cache = ref.read(previewCacheProvider);
    final started = progress.values
        .where((p) => p.isStarted && !p.isCompleted)
        .take(_cards)
        .toList();
    if (started.isEmpty) {
      await precacheImage(
        const AssetImage('assets/illustrations/completed_empty.png'),
        context,
      );
      return;
    }
    await Future.wait([
      for (final picture in started)
        coloredPreview(
          cache,
          assetDir: picture.assetDir,
          size: ColoredPreview.cardSize,
          filled: picture.filled,
        ),
    ]);
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

  /// The first cards of the library.
  Future<void> _libraryCards(BuildContext context) async {
    final pictures = await ref.read(libraryPicturesProvider('all').future);
    final progress = await ref.read(progressProvider.future);
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
    ]);
  }
}

final startupProvider = Provider<Startup>(Startup.new);
