import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../data/models/collectible_card.dart';
import '../../../data/models/player.dart';
import '../../../data/models/rarity.dart';
import '../../../data/models/stadium.dart';
import '../../../data/models/team_jersey.dart';
import '../../../data/providers.dart';
import '../../learning/presentation/widgets/stadium_art.dart';
import '../../learning/presentation/widgets/team_jersey_view.dart';
import 'collection_providers.dart';

class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.card});

  final CollectibleCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedCardsProvider).contains(card.id);

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
                  Row(
                    children: [
                      const GlassBackButton(),
                      const Spacer(),
                      _RarityChip(rarity: card.rarity),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _hero(ref),
                  const SizedBox(height: 18),
                  _details(ref),
                  const SizedBox(height: 18),
                  _statusButton(context, unlocked),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(WidgetRef ref) {
    switch (card.type) {
      case CardType.team:
        return _TeamHero(card: card);
      case CardType.player:
        final player = _player(ref);
        return _PlayerHero(card: card, player: player);
      case CardType.stadium:
        return _StadiumHero(card: card);
    }
  }

  Widget _details(WidgetRef ref) {
    switch (card.type) {
      case CardType.team:
        final team = ref.watch(teamByIdProvider(card.refId));
        if (team == null) return const SizedBox.shrink();
        return Column(
          children: [
            _DetailCard(rows: [
              _Row('FIFA Ranking', '${team.fifaRanking ?? '—'}'),
              _Row('World Cup Wins', '${team.worldCupWins}'),
              _Row('Best Finish', team.bestFinish ?? '—'),
              _Row('Confederation', team.confederation),
              _Row('Head Coach', team.headCoach ?? '—'),
              _Row('Captain', team.captain ?? '—'),
              _Row('First World Cup', '${team.firstWorldCup ?? '—'}'),
              _Row('Most Goals',
                  '${team.topScorerName ?? '—'} (${team.topScorerGoals ?? 0})'),
            ]),
            if (team.fanFact != null) ...[
              const SizedBox(height: 14),
              _FanFact(text: team.fanFact!),
            ],
          ],
        );
      case CardType.player:
        final p = _player(ref);
        if (p == null) return const SizedBox.shrink();
        final team = ref.watch(teamByIdProvider(p.teamId));
        return _DetailCard(rows: [
          _Row('Goals', '${p.goals}'),
          _Row('Matches', '${p.matches}'),
          _Row('Assists', '${p.assists}'),
          _Row('Date of Birth', p.dob ?? '—'),
          _Row('National Team', team?.name ?? '—'),
          _Row('World Cup Apps', '${p.worldCupApps}'),
          _Row('Best World Cup', p.bestFinish ?? '—'),
        ]);
      case CardType.stadium:
        final s = _stadium(ref);
        if (s == null) return const SizedBox.shrink();
        return _DetailCard(rows: [
          _Row('City', s.city),
          _Row('Country', s.country),
          _Row('Capacity', '${s.capacity}'),
          _Row('Year Built', '${s.yearBuilt ?? '—'}'),
          _Row('Nickname', s.nickname ?? '—'),
        ]);
    }
  }

  Widget _statusButton(BuildContext context, bool unlocked) {
    if (unlocked) {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('In Your Collection',
                style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => context.push('/packs'),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 8),
            Text('Locked — open Mystery Packs to unlock',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Player? _player(WidgetRef ref) {
    final players = ref.watch(playersProvider).valueOrNull ?? const [];
    for (final p in players) {
      if (p.id == card.refId) return p;
    }
    return null;
  }

  Stadium? _stadium(WidgetRef ref) {
    final list = ref.watch(stadiumsProvider).valueOrNull ?? const [];
    for (final s in list) {
      if (s.id == card.refId) return s;
    }
    return null;
  }
}

class _TeamHero extends ConsumerWidget {
  const _TeamHero({required this.card});
  final CollectibleCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamByIdProvider(card.refId));
    final specs = ref.watch(jerseysByCodeProvider).valueOrNull;
    TeamJersey? spec;
    if (team != null && specs != null) {
      spec = specs[team.code.toUpperCase()];
    }
    spec ??= TeamJersey.fromColors(
      name: card.name,
      body: card.primaryColor ?? 0xFF1E3A8A,
      accent: card.secondaryColor ?? 0xFFFFFFFF,
    );
    return _HeroFrame(
      rarity: card.rarity,
      child: Column(
        children: [
          JerseyView(spec: spec, size: 150),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(card.emoji ?? '', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                card.name.toUpperCase(),
                style: TextStyle(
                  color: card.rarity.darkText
                      ? const Color(0xFF5B3A00)
                      : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            card.ratingLabel,
            style: const TextStyle(color: AppColors.gold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _PlayerHero extends StatelessWidget {
  const _PlayerHero({required this.card, required this.player});
  final CollectibleCard card;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    final dark = card.rarity.darkText;
    final fg = dark ? const Color(0xFF5B3A00) : Colors.white;
    return _HeroFrame(
      rarity: card.rarity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(card.ratingLabel,
                      style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                          height: 1)),
                  Text(player?.position ?? '',
                      style: TextStyle(
                          color: fg.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(width: 16),
              Icon(Icons.person_rounded, color: fg, size: 78),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            card.name,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w900, fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class _StadiumHero extends StatelessWidget {
  const _StadiumHero({required this.card});
  final CollectibleCard card;

  @override
  Widget build(BuildContext context) {
    return _HeroFrame(
      rarity: card.rarity,
      child: Column(
        children: [
          StadiumArt(seed: 's${card.refId}'.hashCode, size: 230),
          const SizedBox(height: 8),
          Text(
            card.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: card.rarity.darkText ? const Color(0xFF5B3A00) : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.rarity, required this.child});
  final Rarity rarity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: rarity.cardGradient,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: rarity.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: rarity.color.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RarityChip extends StatelessWidget {
  const _RarityChip({required this.rarity});
  final Rarity rarity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: rarity.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rarity.color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: rarity.color, size: 15),
          const SizedBox(width: 6),
          Text(
            rarity.label,
            style: TextStyle(
              color: rarity.color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows});
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    rows[i].label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          ],
        ],
      ),
    );
  }
}

class _FanFact extends StatelessWidget {
  const _FanFact({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fan Fact',
                    style: TextStyle(
                        color: AppColors.info,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(text,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
