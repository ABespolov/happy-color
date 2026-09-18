import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

final selectedFeedSectionProvider =
    NotifierProvider<SelectedFeedSection, FeedSection>(SelectedFeedSection.new);

class SelectedFeedSection extends Notifier<FeedSection> {
  @override
  FeedSection build() => FeedSection.inProgress;

  void select(FeedSection section) => state = section;
}

/// The pictures of a section, taken from what the user has colored or starred.
final feedPicturesProvider =
    Provider.family<AsyncValue<List<FeedPicture>>, FeedSection>(
      (ref, section) => ref
          .watch(progressProvider)
          .whenData(
            (progress) => [
              for (final picture in progress.values)
                if (_belongsTo(picture, section))
                  FeedPicture(id: picture.id, assetDir: picture.assetDir),
            ],
          ),
    );

bool _belongsTo(PictureProgress picture, FeedSection section) =>
    switch (section) {
      FeedSection.inProgress => picture.isStarted && !picture.isCompleted,
      FeedSection.completed => picture.isCompleted,
      FeedSection.starred => picture.starred,
    };
