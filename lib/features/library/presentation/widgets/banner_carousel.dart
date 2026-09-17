import 'package:flutter/material.dart';
import 'package:happy_color/features/library/domain/entities/library_banner.dart';
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

  final _controller = PageController(viewportFraction: _viewportFraction);

  @override
  void dispose() {
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
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: _gap),
                child: BannerCard(banner: widget.banners[index], index: index),
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
