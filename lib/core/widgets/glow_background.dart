import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A single soft radial light bloom.
class GlowSpot {
  const GlowSpot({
    required this.alignment,
    required this.color,
    required this.diameter,
    this.intensity = 0.16,
  });

  final Alignment alignment;
  final Color color;
  final double diameter;
  final double intensity;
}

/// Ambient glowing blobs painted behind content for a "game" atmosphere.
/// Non-interactive; meant to sit in a [Stack] under the real content.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, this.glows = _defaults});

  final List<GlowSpot> glows;

  static const List<GlowSpot> _defaults = [
    // Big bloom rising from the bottom of the screen.
    GlowSpot(
      alignment: Alignment(0, 1.15),
      color: AppColors.primaryGreen,
      diameter: 480,
      intensity: 0.18,
    ),
    // Warm gold accent top-right.
    GlowSpot(
      alignment: Alignment(1.25, -0.75),
      color: AppColors.gold,
      diameter: 340,
      intensity: 0.12,
    ),
    // Cool blue accent left.
    GlowSpot(
      alignment: Alignment(-1.15, 0.15),
      color: AppColors.info,
      diameter: 320,
      intensity: 0.12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final g in glows)
            Align(
              alignment: g.alignment,
              child: Container(
                width: g.diameter,
                height: g.diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      g.color.withValues(alpha: g.intensity),
                      g.color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
