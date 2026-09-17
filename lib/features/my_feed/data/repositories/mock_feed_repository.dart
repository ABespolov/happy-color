import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/features/my_feed/domain/repositories/feed_repository.dart';

/// Placeholder data until real pictures exist.
class MockFeedRepository implements FeedRepository {
  const MockFeedRepository();

  @override
  Future<List<FeedPicture>> getPictures(FeedSection section) async =>
      switch (section) {
        FeedSection.inProgress => [
          for (final category in ['animals', 'nature', 'fantasy'])
            for (var i = 1; i <= 4; i++)
              FeedPicture(
                id: '${category}_$i',
                assetDir: 'assets/pictures/$category/${category}_$i',
              ),
        ],
        FeedSection.completed || FeedSection.starred => const [],
      };
}
