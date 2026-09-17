class LibraryPicture {
  const LibraryPicture({required this.id, required this.assetDir});

  final String id;

  /// Folder with the files written by `tools/generate_picture.py`.
  final String assetDir;
}
