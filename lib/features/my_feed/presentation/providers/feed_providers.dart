import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/my_feed/data/repositories/mock_feed_repository.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/features/my_feed/domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => const MockFeedRepository(),
);

final selectedFeedSectionProvider =
    NotifierProvider<SelectedFeedSection, FeedSection>(SelectedFeedSection.new);

class SelectedFeedSection extends Notifier<FeedSection> {
  @override
  FeedSection build() => FeedSection.inProgress;

  void select(FeedSection section) => state = section;
}

final feedPicturesProvider =
    FutureProvider.family<List<FeedPicture>, FeedSection>(
      (ref, section) => ref.watch(feedRepositoryProvider).getPictures(section),
    );
