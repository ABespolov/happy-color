import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/progress/data/repositories/prefs_progress_repository.dart';
import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';
import 'package:happy_color/features/progress/domain/repositories/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set in main() once shared preferences are ready.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => throw UnimplementedError('override progressRepositoryProvider'),
);

Future<ProgressRepository> createProgressRepository() async =>
    PrefsProgressRepository(await SharedPreferences.getInstance());

/// Progress of every picture the user has touched, by picture id.
final progressProvider =
    AsyncNotifierProvider<ProgressNotifier, Map<String, PictureProgress>>(
      ProgressNotifier.new,
    );

class ProgressNotifier extends AsyncNotifier<Map<String, PictureProgress>> {
  ProgressRepository get _repository => ref.read(progressRepositoryProvider);

  @override
  Future<Map<String, PictureProgress>> build() => _repository.load();

  PictureProgress of(String id, String assetDir) =>
      state.value?[id] ?? PictureProgress(id: id, assetDir: assetDir);

  void setFilled(
    String id,
    String assetDir, {
    required Set<int> filled,
    required int regionCount,
  }) => _update(
    of(id, assetDir).copyWith(filled: filled, regionCount: regionCount),
  );

  void toggleStarred(String id, String assetDir) {
    final progress = of(id, assetDir);
    _update(progress.copyWith(starred: !progress.starred));
  }

  void _update(PictureProgress progress) {
    state = AsyncData({...?state.value, progress.id: progress});
    if (progress.isUntouched) {
      _repository.remove(progress.id);
    } else {
      _repository.save(progress);
    }
  }
}
