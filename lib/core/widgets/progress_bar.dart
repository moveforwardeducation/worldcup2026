import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded progress bar — used on hero card, daily goal, level progression.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.gradient = AppColors.greenCta,
    this.background,
  });

  /// 0..1
  final double progress;
  final double height;
  final LinearGradient gradient;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: background ?? AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: height,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(height),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.last.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
