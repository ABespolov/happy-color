import 'dart:convert';

import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/domain/repositories/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps one entry per picture in shared preferences.
class PrefsProgressRepository implements ProgressRepository {
  PrefsProgressRepository(this._prefs);

  static const _prefix = 'progress/';

  final SharedPreferences _prefs;

  @override
  Future<Map<String, PictureProgress>> load() async {
    final progress = <String, PictureProgress>{};
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(_prefix)) continue;
      final json = _prefs.getString(key);
      if (json == null) continue;
      // Entries written by an older version are dropped, not repaired.
      try {
        final picture = PictureProgress.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        progress[picture.id] = picture;
      } on Object {
        await _prefs.remove(key);
      }
    }
    return progress;
  }

  @override
  Future<void> save(PictureProgress progress) =>
      _prefs.setString('$_prefix${progress.id}', jsonEncode(progress.toJson()));

  @override
  Future<void> remove(String id) => _prefs.remove('$_prefix$id');
}
