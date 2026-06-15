import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_slot.dart';
import '../../../core/widgets/primary_button.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/fan_club_card.dart';
import 'widgets/hero_banner.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_results_card.dart';
import 'widgets/streak_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const HomeHeader(),
              const SizedBox(height: 12),
              const HeroBanner(),
              const SizedBox(height: 20),
              const _ScheduleQuickLink(),
              const SizedBox(height: 16),
              const RecentResultsCard(),
              const SizedBox(height: 20),
              const Center(child: BannerAdSlot()),
              const SizedBox(height: 20),
              const _StandingsQuickLink(),
              const SizedBox(height: 16),
              const StreakCard(),
              const SizedBox(height: 16),
              const FanClubCard(),
              const SizedBox(height: 16),
              const DailyGoalCard(),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Continue Journey',
                trailingIcon: Icons.arrow_forward_rounded,
                gradient: AppColors.goldCta,
                onPressed: () => context.go('/journey'),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Next: Learn Teams',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleQuickLink extends StatelessWidget {
  const _ScheduleQuickLink();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/schedule'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF13235A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.greenCta,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Match Schedule',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Fixtures, your teams & results',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingsQuickLink extends StatelessWidget {
  const _StandingsQuickLink();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/standings'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF14324A), Color(0xFF11233F)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.greenCta,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.format_list_numbered_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group Standings',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Live group tables & qualification',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
