import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Row of up to [max] stars, [filled] of them gold.
class StarRow extends StatelessWidget {
  const StarRow({
    super.key,
    required this.filled,
    this.max = 3,
    this.size = 22,
    this.spacing = 2,
  });

  final int filled;
  final int max;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final on = i < filled;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Icon(
            on ? Icons.star_rounded : Icons.star_outline_rounded,
            color: on ? AppColors.gold : AppColors.textMuted,
            size: size,
            shadows: on
                ? [const Shadow(color: Color(0x88FBBF24), blurRadius: 10)]
                : null,
          ),
        );
      }),
    );
  }
}
