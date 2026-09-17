import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';

abstract interface class FeedRepository {
  Future<List<FeedPicture>> getPictures(FeedSection section);
}
