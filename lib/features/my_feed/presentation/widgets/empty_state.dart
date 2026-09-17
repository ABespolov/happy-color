import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.message,
    required this.action,
    required this.onAction,
  });

  final String illustration;
  final String message;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // Sit a little above the middle, clear of the floating tab bar.
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/illustrations/$illustration.svg',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 32),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: action, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
