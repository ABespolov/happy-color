import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  static const _titleHeight = 40.0;
  static const _padding = EdgeInsets.fromLTRB(16, 32, 16, 24);

  /// Full height including the status bar above the title.
  static double heightOf(BuildContext context) =>
      MediaQuery.paddingOf(context).top + _padding.vertical + _titleHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding.add(
        EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      ),
      child: const SizedBox(
        height: _titleHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Happy coloring!',
            style: TextStyle(
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
