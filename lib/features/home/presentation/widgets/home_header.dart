import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/avatar_chip.dart';
import '../../../../core/widgets/stat_pill.dart';
import '../../../../data/providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final xp = ref.watch(xpProvider);
    final streak = ref.watch(streakProvider);

    return Row(
      children: [
        AvatarChip(
          seed: profile?.avatarSeed ?? 1,
          size: 44,
          label: profile?.username,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.username ?? 'Football Fan',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Level ${xp.level}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        StatPill(
          icon: Icons.local_fire_department_rounded,
          value: '${streak.current}',
          iconColor: AppColors.streakOrange,
        ),
        const SizedBox(width: 8),
        StatPill(
          icon: Icons.monetization_on_rounded,
          value: formatNumber(xp.coins),
          iconColor: AppColors.gold,
        ),
        const SizedBox(width: 6),
        InkResponse(
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 2),
        InkResponse(
          onTap: () => context.push('/settings'),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.settings_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
