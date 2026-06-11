import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/soccer_ball.dart';
import '../../../../data/providers.dart';
import 'confetti.dart';
import 'trophy.dart';

/// Full-bleed hero that sits directly on the screen background — trophy, ball,
/// confetti and the "Road to World Cup 2026" wordmark. No card container.
class HeroBanner extends ConsumerWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    final progress =
        xp.xpForNextLevel == 0 ? 0.0 : xp.xpIntoLevel / xp.xpForNextLevel;
    final pct = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 196,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: Confetti()),
              // Trophy, upper right.
              Positioned(
                right: -6,
                top: 0,
                child: Trophy(size: 132),
              ),
              // Wordmark, left.
              Positioned(
                left: 0,
                top: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOOTBALL',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'CHAMPIONS',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      '2026',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 52,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0x66FBBF24),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Soccer ball, lower area near the wordmark.
              const Positioned(
                left: 150,
                bottom: 2,
                child: SoccerBall(size: 58),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Level ${xp.level}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '$pct%',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppProgressBar(progress: progress.toDouble()),
      ],
    );
  }
}
