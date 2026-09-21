import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/picture_thumbnail.dart';
import 'package:happy_color/features/coloring/presentation/painters/coloring_canvas_painter.dart';
import 'package:happy_color/features/coloring/presentation/rendering/preview_store.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/banner_card.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

/// Warms up what the first screens show, so they do not appear empty and then
/// fill in.
class Startup {
  const Startup(this.ref);

  final Ref ref;

  /// How long the splash screen may wait for [warmUp].
  static const timeout = Duration(seconds: 2);

  static const _cards = 6;

  /// The feed the app opens on; the splash screen waits for it.
  Future<void> warmUp(BuildContext context) =>
      _feed(context).timeout(timeout, onTimeout: () {});

  /// The library and the coloring page, once the feed is up.
  Future<void> warmUpBehind(BuildContext context) async {
    coloringProgram.ignore();
    await Future.wait([
      _banners(context, BannerCard.cacheWidth(context)),
      _libraryCards(context),
    ]);
  }

  Future<void> _feed(BuildContext context) async {
    final progress = await ref.read(progressProvider.future);
    if (!context.mounted) return;
    final previews = ref.read(previewStoreProvider);
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
    final width = pictureThumbnailWidth(context);
    await Future.wait([
      for (final picture in started)
        _cardPreview(context, previews, picture, width),
    ]);
  }

  /// Rendered only if it was never saved, then decoded at the card's width.
  Future<void> _cardPreview(
    BuildContext context,
    PreviewStore previews,
    PictureProgress picture,
    int width,
  ) async {
    final file = await previews.save(picture.assetDir, picture.filled);
    if (!context.mounted) return;
    await precacheImage(ResizeImage(FileImage(file), width: width), context);
  }

  Future<void> _banners(BuildContext context, int width) async {
    final banners = await ref.read(libraryBannersProvider.future);
    if (!context.mounted) return;
    await Future.wait([
      for (final banner in banners)
        if (banner.imageAsset case final asset?)
          precacheImage(ResizeImage(AssetImage(asset), width: width), context),
    ]);
  }

  /// Every category's list too: one not loaded yet shows a spinner for a
  /// frame, and its cards do not cross-fade.
  Future<void> _libraryCards(BuildContext context) async {
    final categories = await ref.read(libraryCategoriesProvider.future);
    for (final category in categories) {
      ref.read(libraryPicturesProvider(category.id).future).ignore();
    }
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
