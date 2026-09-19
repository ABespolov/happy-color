import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/feed_section_ui.dart';

/// Segmented control with a sliding thumb behind the selected section.
class SectionSwitcher extends StatelessWidget {
  const SectionSwitcher({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const height = 48.0;

  final FeedSection selected;
  final ValueChanged<FeedSection> onSelected;

  @override
  Widget build(BuildContext context) {
    const sections = FeedSection.values;
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1 + 2 * selected.index / (sections.length - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / sections.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.trackThumb,
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final section in sections)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(section),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          section.iconAsset(active: section == selected),
                          key: ValueKey((section, section == selected)),
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
