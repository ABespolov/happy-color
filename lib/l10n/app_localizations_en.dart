// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myFeedTab => 'My Feed';

  @override
  String get libraryTab => 'Library';

  @override
  String get moreTab => 'More';

  @override
  String get inProgressSection => 'In Progress';

  @override
  String get completedSection => 'Completed';

  @override
  String get starredSection => 'Starred';

  @override
  String get starredEmpty =>
      'Long tap pictures you want to color to save them here';

  @override
  String get starredEmptyAction => 'Try';

  @override
  String get completedEmpty => 'All your completed pictures are saved here';

  @override
  String get completedEmptyAction => 'Start coloring';

  @override
  String get continueColoring => 'Continue';

  @override
  String get colorAgain => 'Color again';

  @override
  String get fillAllTooltip => 'Open every region of the selected color';

  @override
  String loadingFailed(String error) {
    return 'Could not load: $error';
  }
}
