import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';

/// Presentation details for each [FeedSection].
extension FeedSectionUi on FeedSection {
  String get title => switch (this) {
    FeedSection.inProgress => 'In Progress',
    FeedSection.completed => 'Completed',
    FeedSection.starred => 'Starred',
  };

  String iconAsset({required bool active}) {
    final name = switch (this) {
      FeedSection.inProgress => 'brush',
      FeedSection.completed => 'check',
      FeedSection.starred => 'star',
    };
    return 'assets/icons/feed/${name}_${active ? 'active' : 'inactive'}.svg';
  }
}
