import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/library/domain/entities/library_category.dart';

/// Horizontally scrolling category names with an underline that slides to the
/// selected one.
class CategoryTabs extends StatefulWidget {
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

  static const _style = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const _padding = 20.0;
  static const _gap = 28.0;

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Measured once: every frame the underline moves is a build.
  late List<double> _widths;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _widths = _measure();
  }

  @override
  void didUpdateWidget(CategoryTabs old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.categories, widget.categories)) _widths = _measure();
    if (old.selectedId != widget.selectedId) _showSelected();
  }

  void _showSelected() {
    if (!_scroll.hasClients || widget.categories.isEmpty) return;
    final widths = _widths;
    final index = _selectedIndex;
    var start = CategoryTabs._padding;
    for (var i = 0; i < index; i++) {
      start += widths[i] + CategoryTabs._gap;
    }
    final end = start + widths[index];
    final viewport = _scroll.position.viewportDimension;
    final offset = _scroll.offset;
    final target = switch (0) {
      _ when start - CategoryTabs._gap < offset =>
        start - CategoryTabs._gap - CategoryTabs._padding,
      _ when end + CategoryTabs._gap > offset + viewport =>
        end + CategoryTabs._gap + CategoryTabs._padding - viewport,
      _ => offset,
    };
    _scroll.animateTo(
      target.clamp(0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  int get _selectedIndex {
    final index = widget.categories.indexWhere(
      (category) => category.id == widget.selectedId,
    );
    return index < 0 ? 0 : index;
  }

  List<double> _measure() => [
    for (final category in widget.categories)
      (TextPainter(
        text: TextSpan(text: category.title, style: CategoryTabs._style),
        textDirection: Directionality.of(context),
      )..layout()).width,
  ];

  @override
  Widget build(BuildContext context) {
    // The categories arrive a frame later than the bar itself.
    if (widget.categories.isEmpty) {
      return const SizedBox(height: CategoryTabs.height);
    }
    final widths = _widths;
    final index = _selectedIndex;
    var underlineStart = CategoryTabs._padding;
    for (var i = 0; i < index; i++) {
      underlineStart += widths[i] + CategoryTabs._gap;
    }
    return SizedBox(
      height: CategoryTabs.height,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CategoryTabs._padding),
        child: Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: CategoryTabs._gap),
                  _CategoryTab(
                    key: ValueKey(widget.categories[i].id),
                    title: widget.categories[i].title,
                    selected: i == index,
                    onTap: () => widget.onSelected(widget.categories[i].id),
                  ),
                ],
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: underlineStart - CategoryTabs._padding,
              width: widths[index],
              bottom: 8,
              height: 3,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.text,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Its weight never changes, so the row never shifts.
class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
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
      child: Align(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: CategoryTabs._style.copyWith(
            color: selected ? AppColors.text : AppColors.ink,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}
