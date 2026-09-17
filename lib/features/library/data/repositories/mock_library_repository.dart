import 'package:happy_color/features/library/domain/entities/library_banner.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';
import 'package:happy_color/features/library/domain/repositories/library_repository.dart';

/// Placeholder data until real banners and pictures exist.
class MockLibraryRepository implements LibraryRepository {
  const MockLibraryRepository();

  static const _categories = [
    LibraryCategory(id: 'all', title: 'All'),
    LibraryCategory(id: 'for_you', title: 'For You'),
    LibraryCategory(id: 'popular', title: 'Popular'),
    LibraryCategory(id: 'animals', title: 'Animals'),
    LibraryCategory(id: 'nature', title: 'Nature'),
    LibraryCategory(id: 'fantasy', title: 'Fantasy'),
  ];

  @override
  Future<List<LibraryBanner>> getBanners() async => [
    for (var i = 1; i <= 5; i++)
      LibraryBanner(id: 'banner-$i', title: 'New collection $i'),
  ];

  @override
  Future<List<LibraryCategory>> getCategories() async => _categories;

  @override
  Future<List<LibraryPicture>> getPictures(String categoryId) async => [
    for (var i = 0; i < 12; i++) LibraryPicture(id: '$categoryId-$i'),
  ];
}
