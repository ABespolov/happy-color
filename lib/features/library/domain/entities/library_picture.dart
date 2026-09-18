import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_picture.freezed.dart';

@freezed
abstract class LibraryPicture with _$LibraryPicture {
  const factory LibraryPicture({
    required String id,

    /// Folder with the files written by `tools/generate_picture.py`.
    required String assetDir,
  }) = _LibraryPicture;
}
