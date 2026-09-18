import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/library_picture_card.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// Sliver grid with the pictures of a category.
class LibraryPictureGrid extends ConsumerWidget {
  const LibraryPictureGrid({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictures = ref.watch(libraryPicturesProvider(categoryId));
    return switch (pictures) {
      AsyncData(:final value) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: value.length,
          itemBuilder: (context, index) =>
              LibraryPictureCard(picture: value[index]),
        ),
      ),
      AsyncError(:final error) => SliverToBoxAdapter(
        child: Center(
          child: Text(AppLocalizations.of(context)!.loadingFailed('$error')),
        ),
      ),
      _ => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    };
  }
}
