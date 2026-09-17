import 'package:happy_color/features/library/domain/entities/library_banner.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';
import 'package:happy_color/features/library/domain/repositories/library_repository.dart';

/// Placeholder data until real banners and pictures exist.
class MockLibraryRepository implements LibraryRepository {
  const MockLibraryRepository();

  static const _categories = [
    LibraryCategory(id: 'all', title: 'All'),
    LibraryCategory(id: 'popular', title: 'Popular'),
    LibraryCategory(id: 'animals', title: 'Animals'),
    LibraryCategory(id: 'nature', title: 'Nature'),
    LibraryCategory(id: 'fantasy', title: 'Fantasy'),
  ];

  /// Categories that own pictures; `all` and `popular` are selections.
  static const _contentCategories = ['animals', 'nature', 'fantasy'];

  static const _picturesPerCategory = 8;

  // Temporary: every asset folder is a copy of the test fox.
  static final _picturesByCategory = {
    for (final category in _contentCategories)
      category: [
        for (var i = 1; i <= _picturesPerCategory; i++)
          LibraryPicture(
            id: '${category}_$i',
            assetDir: 'assets/pictures/$category/${category}_$i',
          ),
      ],
  };

  @override
  Future<List<LibraryBanner>> getBanners() async => [
    for (var i = 1; i <= 5; i++)
      LibraryBanner(id: 'banner-$i', title: 'New collection $i'),
  ];

  @override
  Future<List<LibraryCategory>> getCategories() async => _categories;

  @override
  Future<List<LibraryPicture>> getPictures(
    String categoryId,
  ) async => switch (categoryId) {
    'all' => [for (final pictures in _picturesByCategory.values) ...pictures],
    'popular' => [
      for (final pictures in _picturesByCategory.values) ...pictures.take(3),
    ],
    _ => _picturesByCategory[categoryId] ?? const [],
  };
}
