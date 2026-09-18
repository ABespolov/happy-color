import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_category.freezed.dart';

@freezed
abstract class LibraryCategory with _$LibraryCategory {
  const factory LibraryCategory({required String id, required String title}) =
      _LibraryCategory;
}
