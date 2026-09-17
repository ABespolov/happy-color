import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';

/// Dots where the pill follows the swipe continuously.
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.count, required this.page});

  final int count;

  /// Fractional page position, e.g. 1.4 while swiping from page 1 to 2.
  final double page;

  static const dotSize = 8.0;
  static const _dot = dotSize;
  static const _pill = 22.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final active = Curves.easeInOut.transform(
                (1 - (page - i).abs()).clamp(0.0, 1.0),
              );
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _dot + (_pill - _dot) * active,
                height: _dot,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    AppColors.indicatorInactive,
                    AppColors.indicatorActive,
                    active,
                  ),
                  borderRadius: BorderRadius.circular(_dot / 2),
                ),
              );
            },
          ),
      ],
    );
  }
}
