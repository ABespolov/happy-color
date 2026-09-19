import 'dart:async';

import 'package:flutter/material.dart';
import 'package:happy_color/features/library/domain/entities/library_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/router.dart';
import 'package:happy_color/features/library/presentation/widgets/banner_card.dart';
import 'package:happy_color/features/library/presentation/widgets/page_indicator.dart';

/// Swipeable banners with neighbours peeking from the sides.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners});

  final List<LibraryBanner> banners;

  /// Height of the carousel with its page indicator for a given [width].
  static double heightFor(double width) =>
      _BannerCarouselState.cardHeightFor(width) +
      _BannerCarouselState._indicatorSpacing +
      PageIndicator.dotSize;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const _viewportFraction = 0.84;
  static const _gap = 8.0;

  /// Width to height of a single banner card.
  static const _cardAspectRatio = 1.9;

  static const _indicatorSpacing = 14.0;

  static double cardHeightFor(double width) =>
      (width * _viewportFraction - _gap * 2) / _cardAspectRatio;

  /// Pause between automatic page turns.
  static const _autoScrollInterval = Duration(seconds: 4);

  final _controller = PageController(viewportFraction: _viewportFraction);

  /// Turns pages until the user touches the banners for the first time.
  Timer? _autoScroll;

  @override
  void initState() {
    super.initState();
    _autoScroll = Timer.periodic(_autoScrollInterval, (_) => _showNextPage());
  }

  void _showNextPage() {
    // Library sits in an IndexedStack: skip turns while another tab is shown.
    if (!TickerMode.valuesOf(context).enabled || !_controller.hasClients) {
      return;
    }
    final next = (_controller.page ?? 0).round() + 1;
    _controller.animateToPage(
      next % widget.banners.length,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _stopAutoScroll() {
    _autoScroll?.cancel();
    _autoScroll = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: cardHeightFor(constraints.maxWidth),
            child: Listener(
              onPointerDown: (_) => _stopAutoScroll(),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.banners.length,
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return Padding(
                    key: ValueKey(banner.id),
                    padding: const EdgeInsets.symmetric(horizontal: _gap),
                    child: GestureDetector(
                      onTap: () => context.push(Routes.collection(banner.id)),
                      child: BannerCard(banner: banner, index: index),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: _indicatorSpacing),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => PageIndicator(
            count: widget.banners.length,
            page:
                _controller.hasClients &&
                    _controller.position.hasContentDimensions
                ? _controller.page ?? 0
                : 0,
          ),
        ),
      ],
    );
  }
}
