import 'package:freezed_annotation/freezed_annotation.dart';

part 'picture_progress.freezed.dart';
part 'picture_progress.g.dart';

/// What the user has done with one picture: which regions are colored and
/// whether it is starred.
@freezed
abstract class PictureProgress with _$PictureProgress {
  const factory PictureProgress({
    required String id,
    @JsonKey(name: 'dir') required String assetDir,

    /// Indices of the regions that are already colored.
    @Default(<int>{}) Set<int> filled,

    /// Regions in the picture; 0 until it has been opened once.
    @JsonKey(name: 'regions') @Default(0) int regionCount,
    @Default(false) bool starred,
  }) = _PictureProgress;

  const PictureProgress._();

  factory PictureProgress.fromJson(Map<String, dynamic> json) =>
      _$PictureProgressFromJson(json);

  bool get isStarted => filled.isNotEmpty;

  bool get isCompleted => regionCount > 0 && filled.length >= regionCount;

  bool get isUntouched => filled.isEmpty && !starred;

  double get fraction => regionCount == 0 ? 0 : filled.length / regionCount;
}
