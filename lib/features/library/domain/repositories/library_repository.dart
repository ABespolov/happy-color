import 'package:happy_color/features/library/domain/entities/library_banner.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';

abstract interface class LibraryRepository {
  Future<List<LibraryBanner>> getBanners();

  Future<List<LibraryCategory>> getCategories();

  Future<List<LibraryPicture>> getPictures(String categoryId);
}
