import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_banner.freezed.dart';

@freezed
abstract class LibraryBanner with _$LibraryBanner {
  const factory LibraryBanner({
    required String id,
    required String title,

    /// Banner artwork; `null` until the image is added.
    String? imageAsset,
  }) = _LibraryBanner;
}
