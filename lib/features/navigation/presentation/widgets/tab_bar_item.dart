import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';

typedef TabIconBuilder = Widget Function(Animation<double> progress);

/// A tab with an icon that plays its animation on every tap.
class TabBarItem extends StatefulWidget {
  const TabBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final TabIconBuilder icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<TabBarItem> createState() => _TabBarItemState();
}

class _TabBarItemState extends State<TabBarItem>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(dimension: 38, child: widget.icon(_controller)),
          const SizedBox(height: 1),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: widget.selected
                  ? AppColors.tabLabelSelected
                  : AppColors.tabLabel,
            ),
            child: Text(widget.label),
          ),
        ],
      ),
    );
  }
}
