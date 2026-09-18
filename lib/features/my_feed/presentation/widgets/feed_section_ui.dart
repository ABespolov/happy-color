import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// Presentation details for each [FeedSection].
extension FeedSectionUi on FeedSection {
  String title(AppLocalizations l10n) => switch (this) {
    FeedSection.inProgress => l10n.inProgressSection,
    FeedSection.completed => l10n.completedSection,
    FeedSection.starred => l10n.starredSection,
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
