import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Procedurally-colored circular avatar. Uses [seed] to pick a hue so we
/// don't need real avatar images.
class AvatarChip extends StatelessWidget {
  const AvatarChip({
    super.key,
    required this.seed,
    this.size = 44,
    this.label,
  });

  final int seed;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final hue = (seed * 47) % 360;
    final c1 = HSLColor.fromAHSL(1, hue.toDouble(), 0.7, 0.6).toColor();
    final c2 = HSLColor.fromAHSL(1, (hue + 30) % 360, 0.7, 0.45).toColor();
    final initial = (label ?? '').isNotEmpty
        ? label!.characters.first.toUpperCase()
        : '⚽';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceHigh, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
