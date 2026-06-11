import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/help_button.dart';
import '../../../../core/widgets/streak_dots.dart';
import '../../../../data/providers.dart';
import '../../../help/help_content.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    return GradientCard(
      color: AppColors.glassFill,
      borderColor: AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.streakOrange,
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                '${streak.current} Day Streak',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              HelpButton(topic: AppHelp.streak, size: 26),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep it up! Play daily to keep your streak.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          StreakDots(last7Days: streak.last7Days),
        ],
      ),
    );
  }
}
