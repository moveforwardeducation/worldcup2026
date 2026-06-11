import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../data/models/achievement.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../../home/presentation/widgets/trophy.dart';
import 'achievements_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(achievementsProvider);
    final unlocked = items.where((a) => a.unlocked).length;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  BannerHeader(
                    title: 'Achievements',
                    subtitle: '$unlocked of ${items.length} unlocked',
                    backdrop: const Confetti(),
                    emblem: const Trophy(size: 96),
                    action: HelpButton(topic: AppHelp.achievements),
                  ),
                  const SizedBox(height: 14),
                  for (final a in items) ...[
                    _AchievementTile(achievement: a),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final done = achievement.unlocked;
    final accent = done ? AppColors.primaryGreen : AppColors.gold;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: done
              ? [
                  AppColors.primaryGreen.withValues(alpha: 0.18),
                  AppColors.primaryGreen.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: done
              ? AppColors.primaryGreen.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(achievement.icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (done)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primaryGreen, size: 20)
                    else
                      Text(
                        '${achievement.clampedCurrent}/${achievement.target}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (done)
                  Row(
                    children: [
                      _reward(Icons.bolt_rounded, AppColors.primaryGreen,
                          '+${achievement.rewardXp} XP'),
                      const SizedBox(width: 10),
                      _reward(Icons.monetization_on_rounded, AppColors.gold,
                          '+${achievement.rewardCoins}'),
                    ],
                  )
                else
                  AppProgressBar(progress: achievement.progress, height: 7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reward(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 11)),
      ],
    );
  }
}
