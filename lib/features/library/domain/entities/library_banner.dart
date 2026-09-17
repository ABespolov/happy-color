class LibraryBanner {
  const LibraryBanner({required this.id, required this.title, this.imageAsset});

  final String id;
  final String title;

  /// Banner artwork; `null` until the image is added.
  final String? imageAsset;
}
