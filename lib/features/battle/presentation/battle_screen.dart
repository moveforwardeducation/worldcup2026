import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_chip.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/providers.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../data/battle_repository.dart';
import 'battle_providers.dart';

const List<String> kOpponentNames = [
  'Rahul', 'Sofia', 'Chen', 'Diego', 'Amara', 'Yuki', 'Marco', 'Lena'
];

class BattleScreen extends ConsumerWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final trophies = ref.watch(trophiesProvider);
    final board = ref.watch(battleLeaderboardProvider);

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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  BannerHeader(
                    title: 'Battle',
                    subtitle: 'Football knowledge — head to head',
                    showBack: false,
                    backdrop: const Confetti(),
                    emblem: const _BattleEmblem(),
                    action: HelpButton(topic: AppHelp.battle),
                  ),
                  const SizedBox(height: 6),
                  _VsCard(
                    youName: profile?.username ?? 'You',
                    youSeed: profile?.avatarSeed ?? 1,
                    trophies: trophies,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Start Battle',
                    icon: Icons.sports_kabaddi_rounded,
                    onPressed: () {
                      final opp = kOpponentNames[
                          math.Random().nextInt(kOpponentNames.length)];
                      context.push('/battle/match', extra: opp);
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text('Battle Leaderboard',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const SizedBox(height: 12),
                  board.when(
                    loading: () => const Center(
                        child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    )),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (entries) => Column(
                      children: [
                        for (var i = 0; i < entries.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _BattleRow(rank: i + 1, entry: entries[i]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VsCard extends StatelessWidget {
  const _VsCard({
    required this.youName,
    required this.youSeed,
    required this.trophies,
  });
  final String youName;
  final int youSeed;
  final int trophies;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _side(youName, youSeed)),
              const Text('VS',
                  style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
              Expanded(
                child: Column(
                  children: const [
                    Icon(Icons.person_search_rounded,
                        color: AppColors.textSecondary, size: 56),
                    SizedBox(height: 8),
                    Text('Random Rival',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.gold, size: 18),
                const SizedBox(width: 6),
                Text('$trophies Trophies · Best of 5',
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _side(String name, int seed) {
    return Column(
      children: [
        AvatarChip(seed: seed, size: 56, label: name),
        const SizedBox(height: 8),
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
      ],
    );
  }
}

class _BattleRow extends StatelessWidget {
  const _BattleRow({required this.rank, required this.entry});
  final int rank;
  final BattleEntry entry;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFC0C7D4),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isYou
            ? AppColors.primaryGreen.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isYou
              ? AppColors.primaryGreen.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text('$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: medal,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ),
          const SizedBox(width: 8),
          AvatarChip(seed: entry.name.hashCode, size: 30, label: entry.name),
          const SizedBox(width: 12),
          Expanded(
            child: Text(entry.isYou ? '${entry.name} (You)' : entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.gold, size: 16),
          const SizedBox(width: 4),
          Text(formatNumber(entry.trophies),
              style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _BattleEmblem extends StatelessWidget {
  const _BattleEmblem();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.sports_kabaddi_rounded,
          color: Colors.white, size: 44),
    );
  }
}
