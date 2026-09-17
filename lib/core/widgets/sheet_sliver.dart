import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';

/// Page layout for a full-screen [CustomScrollView]: [top] content followed by
/// a rounded-top sheet with a [header] and the [slivers] below it.
///
/// While scrolling, [top] slides under the status bar. Once the sheet reaches
/// it, the header stays pinned: the status bar area takes the sheet color so
/// the content passes underneath, and the rounded corners straighten out.
class SheetSliver extends StatelessWidget {
  const SheetSliver({
    super.key,
    required this.top,
    required this.topHeight,
    required this.header,
    required this.headerHeight,
    required this.slivers,
  });

  final Widget top;
  final double topHeight;
  final Widget header;
  final double headerHeight;
  final List<Widget> slivers;

  static const radius = 32.0;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CollapsingSheetHeaderDelegate(
            statusBar: MediaQuery.paddingOf(context).top,
            top: top,
            topHeight: topHeight,
            header: header,
            headerHeight: headerHeight,
          ),
        ),
        DecoratedSliver(
          decoration: const BoxDecoration(color: AppColors.sheet),
          sliver: SliverMainAxisGroup(
            slivers: [
              ...slivers,
              // Leave room for the floating tab bar.
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollapsingSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingSheetHeaderDelegate({
    required this.statusBar,
    required this.top,
    required this.topHeight,
    required this.header,
    required this.headerHeight,
  });

  final double statusBar;
  final Widget top;
  final double topHeight;
  final Widget header;
  final double headerHeight;

  static const _cornerSpace = SheetSliver.radius / 2;

  double get _sheetHeight => _cornerSpace + headerHeight;

  @override
  double get maxExtent => math.max(topHeight, statusBar) + _sheetHeight;

  @override
  double get minExtent => statusBar + _sheetHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    // 0 while the sheet moves up, 1 once it has settled under the status bar.
    final collapse = maxExtent - minExtent;
    final pinned = collapse == 0
        ? 1.0
        : ((shrinkOffset - collapse + _cornerSpace) / _cornerSpace).clamp(
            0.0,
            1.0,
          );
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -shrinkOffset,
          left: 0,
          right: 0,
          height: topHeight,
          child: top,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBar,
          child: IgnorePointer(
            child: ColoredBox(color: AppColors.sheet.withValues(alpha: pinned)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _sheetHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  lerpDouble(SheetSliver.radius, 0, pinned)!,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: _cornerSpace),
              child: header,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_CollapsingSheetHeaderDelegate oldDelegate) => true;
}
