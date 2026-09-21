import 'package:flutter/material.dart';
import 'package:happy_color/features/library/domain/entities/library_banner.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({super.key, required this.banner, required this.index});

  final LibraryBanner banner;

  /// Picks the placeholder gradient while the banner has no image.
  final int index;

  static const _placeholders = [
    [Color(0xFFF59B8F), Color(0xFFE86B7A)],
    [Color(0xFF9FC0F5), Color(0xFF6F93DD)],
    [Color(0xFFF9D98A), Color(0xFFF0A93B)],
    [Color(0xFFB9E3C6), Color(0xFF5CC47E)],
    [Color(0xFFD9C2F0), Color(0xFFA785D6)],
  ];

  /// The same everywhere, so the image cache holds one copy of each banner.
  static int cacheWidth(BuildContext context) =>
      (MediaQuery.sizeOf(context).width *
              MediaQuery.devicePixelRatioOf(context))
          .round();

  @override
  Widget build(BuildContext context) {
    final image = banner.imageAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: image != null
          ? Image.asset(
              image,
              fit: BoxFit.cover,
              cacheWidth: cacheWidth(context),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _placeholders[index % _placeholders.length],
                ),
              ),
              child: Center(
                child: Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }
}
