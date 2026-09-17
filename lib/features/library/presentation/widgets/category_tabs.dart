import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';

/// Horizontally scrolling category names with an underline on the selected one.
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  static const height = 48.0;

  final List<LibraryCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 28),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryTab(
            title: category.title,
            selected: category.id == selectedId,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  const CategoryTab({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 20,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.text,
              ),
              child: Text(title),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.text,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
