import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';

/// Round icon button floating over content, like the back arrow on the
/// collection and coloring screens.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconSize = 18,
    this.size = 44,
    this.background = Colors.white,
    this.elevation = 2,
    this.iconColor = AppColors.ink,
  });

  /// Goes back, which is what most of these buttons do.
  factory CircleIconButton.back(
    BuildContext context, {
    Color background = Colors.white,
    double elevation = 2,
  }) => CircleIconButton(
    icon: Icons.arrow_back_ios_new,
    iconSize: 16,
    background: background,
    elevation: elevation,
    onTap: Navigator.of(context).pop,
  );

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final double size;
  final Color background;
  final double elevation;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: background,
        shadows: elevation == 0
            ? null
            : [
                BoxShadow(
                  color: AppColors.tabBarShadow,
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
