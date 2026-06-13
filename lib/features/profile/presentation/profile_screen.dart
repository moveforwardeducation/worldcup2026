import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/stats_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_chip.dart';
import '../../../core/widgets/banner_ad_slot.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../data/models/achievement.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../../../data/providers.dart';
import '../../achievements/presentation/achievements_providers.dart';
import '../../collection/presentation/collection_providers.dart';
import '../../packs/presentation/packs_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final xp = ref.watch(xpProvider);
    final stats = ref.watch(statsProvider);
    final cards = ref.watch(collectionCountProvider);
    final packs = ref.watch(packsCountProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlockedAch = achievements.where((a) => a.unlocked).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Stack(
                    children: [
                      const Positioned.fill(
                          child: IgnorePointer(child: Confetti())),
                      _Header(
                        username: profile?.username ?? 'Football Fan',
                        avatarSeed: profile?.avatarSeed ?? 1,
                        level: xp.level,
                        into: xp.xpIntoLevel,
                        next: xp.xpForNextLevel,
                        onEditAvatar: () => _editAvatar(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatTile(
                          label: 'Lessons',
                          value: formatNumber(stats.lessonsCompleted)),
                      const SizedBox(width: 12),
                      _StatTile(
                          label: 'Correct',
                          value: formatNumber(stats.totalCorrect)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatTile(
                          label: 'Accuracy', value: '${stats.accuracyPct}%'),
                      const SizedBox(width: 12),
                      _StatTile(label: 'Cards', value: '$cards'),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Center(child: BannerAdSlot()),
                  const SizedBox(height: 22),
                  _BadgesSection(unlocked: unlockedAch),
                  const SizedBox(height: 22),
                  _MenuCard(
                    icon: Icons.style_rounded,
                    color: AppColors.rarityEpic,
                    title: 'My Collection',
                    subtitle: '$cards cards collected',
                    onTap: () => context.push('/collection'),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.card_giftcard_rounded,
                    color: AppColors.gold,
                    title: 'Mystery Packs',
                    subtitle: packs > 0
                        ? '$packs pack${packs == 1 ? '' : 's'} ready to open'
                        : 'No packs available',
                    onTap: () => context.push('/packs'),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.primaryGreen,
                    title: 'Achievements',
                    subtitle: '${unlockedAch.length} of ${achievements.length} unlocked',
                    onTap: () => context.push('/achievements'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editAvatar(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your avatar',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (final seed in [1, 7, 13, 21, 34, 42, 55, 68])
                  GestureDetector(
                    onTap: () {
                      ref.read(userProfileProvider.notifier).save(
                            profile.copyWith(avatarSeed: seed),
                          );
                      Navigator.pop(ctx);
                    },
                    child: AvatarChip(
                      seed: seed,
                      size: 56,
                      label: profile.username,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.username,
    required this.avatarSeed,
    required this.level,
    required this.into,
    required this.next,
    required this.onEditAvatar,
  });

  final String username;
  final int avatarSeed;
  final int level;
  final int into;
  final int next;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            const Text(
              'Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            AvatarChip(seed: avatarSeed, size: 96, label: username),
            GestureDetector(
              onTap: onEditAvatar,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  gradient: AppColors.greenCta,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          username,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Level $level',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppProgressBar(progress: next == 0 ? 0 : into / next),
        const SizedBox(height: 6),
        Text(
          '${formatNumber(into)} / ${formatNumber(next)} XP',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.unlocked});
  final List<Achievement> unlocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Badges',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => GoRouter.of(context).push('/achievements'),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (unlocked.isEmpty)
          const Text(
            'Earn badges by completing achievements.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          )
        else
          Row(
            children: [
              for (final a in unlocked.take(5))
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldCta,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(a.icon, color: Colors.white, size: 26),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
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
