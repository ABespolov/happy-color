import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/library/data/repositories/mock_library_repository.dart';
import 'package:happy_color/features/library/domain/entities/library_banner.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';
import 'package:happy_color/features/library/domain/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => const MockLibraryRepository(),
);

final libraryBannersProvider = FutureProvider<List<LibraryBanner>>(
  (ref) => ref.watch(libraryRepositoryProvider).getBanners(),
);

final libraryCategoriesProvider = FutureProvider<List<LibraryCategory>>(
  (ref) => ref.watch(libraryRepositoryProvider).getCategories(),
);

final selectedCategoryProvider = NotifierProvider<SelectedCategory, String>(
  SelectedCategory.new,
);

class SelectedCategory extends Notifier<String> {
  @override
  String build() => 'all';

  void select(String categoryId) => state = categoryId;
}

final libraryPicturesProvider =
    FutureProvider.family<List<LibraryPicture>, String>(
      (ref, categoryId) =>
          ref.watch(libraryRepositoryProvider).getPictures(categoryId),
    );
