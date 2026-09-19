import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';

/// Page title over the header gradient, above the sheet.
///
/// [background] paints that gradient behind a whole page.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title});

  final String title;

  static const _titleHeight = 40.0;
  static const _padding = EdgeInsets.fromLTRB(16, 32, 16, 24);

  /// Full height including the status bar above the title.
  static double heightOf(BuildContext context) =>
      MediaQuery.paddingOf(context).top + _padding.vertical + _titleHeight;

  static const background = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: AppColors.headerGradient,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding.add(
        EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      ),
      child: SizedBox(
        height: _titleHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
