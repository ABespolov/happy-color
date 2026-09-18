import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_picture.freezed.dart';

@freezed
abstract class FeedPicture with _$FeedPicture {
  const factory FeedPicture({required String id, required String assetDir}) =
      _FeedPicture;
}
