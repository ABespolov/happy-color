import 'package:happy_color/features/progress/domain/entities/picture_progress.dart';

abstract interface class ProgressRepository {
  /// Progress of every picture the user has touched, by picture id.
  Future<Map<String, PictureProgress>> load();

  Future<void> save(PictureProgress progress);

  Future<void> remove(String id);
}
