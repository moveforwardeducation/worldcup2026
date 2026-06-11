import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/xp_rules.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/help_button.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../data/providers.dart';
import '../../../help/help_content.dart';

class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    return GradientCard(
      color: AppColors.glassFill,
      borderColor: AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Daily Goal',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        HelpButton(topic: AppHelp.dailyGoal, size: 24),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Earn ${XpRules.dailyGoalXp} XP',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${xp.dailyXpEarned} / ${XpRules.dailyGoalXp} XP',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              _RewardChest(unlocked: xp.dailyGoalProgress >= 1),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(
            progress: xp.dailyGoalProgress,
            gradient: AppColors.goldCta,
          ),
        ],
      ),
    );
  }
}

class _RewardChest extends StatelessWidget {
  const _RewardChest({required this.unlocked});
  final bool unlocked;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: unlocked ? AppColors.goldCta : null,
        color: unlocked ? null : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.card_giftcard_rounded,
        color: unlocked ? Colors.white : AppColors.gold,
        size: 22,
      ),
    );
  }
}
