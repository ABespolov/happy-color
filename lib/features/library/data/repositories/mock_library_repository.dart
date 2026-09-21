import 'package:happy_color/features/library/domain/entities/library_banner.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';
import 'package:happy_color/features/library/domain/repositories/library_repository.dart';

/// Placeholder data until real banners and pictures exist.
class MockLibraryRepository implements LibraryRepository {
  const MockLibraryRepository();

  static const _categories = [
    LibraryCategory(id: 'all', title: 'All'),
    LibraryCategory(id: 'animals', title: 'Animals'),
    LibraryCategory(id: 'nature', title: 'Nature'),
    LibraryCategory(id: 'fantasy', title: 'Fantasy'),
    LibraryCategory(id: 'food', title: 'Food'),
    LibraryCategory(id: 'cities', title: 'Cities'),
  ];

  /// Categories that own pictures; `all` shows every one of them.
  static const _contentCategories = [
    'animals',
    'cities',
    'fantasy',
    'nature',
    'food',
  ];

  static const _picturesPerCategory = 8;

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

  static final _banners = [
    for (final category in _contentCategories)
      LibraryBanner(
        id: category,
        title: category,
        imageAsset: 'assets/banners/$category.webp',
      ),
  ];

  @override
  Future<List<LibraryBanner>> getBanners() async => _banners;

  @override
  Future<List<LibraryCategory>> getCategories() async => _categories;

  @override
  Future<List<LibraryPicture>> getPictures(String categoryId) async =>
      switch (categoryId) {
        'all' => [
          for (final pictures in _picturesByCategory.values) ...pictures,
        ],
        _ => _picturesByCategory[categoryId] ?? const [],
      };
}
