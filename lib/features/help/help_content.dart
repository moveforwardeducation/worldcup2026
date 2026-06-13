import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/help_button.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/star_row.dart';
import '../../core/widgets/streak_dots.dart';
import '../../data/models/collectible_card.dart';
import '../../data/models/rarity.dart';
import '../collection/presentation/widgets/card_tile.dart';
import '../packs/presentation/widgets/pack_box.dart';

/// Central catalogue of all in-app help topics (with visual previews).
class AppHelp {
  AppHelp._();

  // ---- Home cards ----

  static const streak = HelpTopic(
    title: 'Daily Streak',
    icon: Icons.local_fire_department_rounded,
    intro: 'Your streak counts the days in a row you stay active.',
    points: [
      'Earn any XP in a day to keep the streak alive.',
      'Each active day fills a flame; today is the orange one.',
      'Miss a day and the streak resets to zero.',
      'Hit milestones (like 14 days) to unlock achievements.',
    ],
    preview: _StreakPreview(),
  );

  static const fanClub = HelpTopic(
    title: 'Your Fan Club',
    icon: Icons.shield_rounded,
    intro: 'You support a club — every XP you earn powers its world ranking.',
    points: [
      'Your primary club receives all the XP you earn.',
      'Clubs are ranked against each other on the Club tab.',
      'Climb the global and country leaderboards as you play.',
    ],
    preview: _FanClubPreview(),
  );

  static const dailyGoal = HelpTopic(
    title: 'Daily Goal',
    icon: Icons.flag_rounded,
    intro: 'A small XP target to hit each day.',
    points: [
      'Earn 150 XP in a day to complete your goal.',
      'The bar fills as you play lessons, predict and battle.',
      'Finish it to claim the reward chest.',
    ],
    preview: _DailyGoalPreview(),
  );

  // ---- Screens ----

  static const journey = HelpTopic(
    title: 'Your Journey',
    icon: Icons.map_rounded,
    intro: 'A path of stages from Learn Teams all the way to the Final.',
    points: [
      'Complete a stage\'s lessons to unlock the next stage.',
      'Each lesson awards stars (up to 3) based on accuracy.',
      'A perfect lesson earns bonus XP — and level-ups drop packs.',
    ],
    preview: _JourneyPreview(),
  );

  static const predict = HelpTopic(
    title: 'Predictions',
    icon: Icons.online_prediction_rounded,
    intro: 'Vote on outcomes and see what the crowd thinks.',
    points: [
      'Only matches kicking off within 24h are open to predict.',
      'Tap an option to pick; change it freely until kickoff, then it locks.',
      'See the live community split (%) on every poll.',
      'Pick group winners too. Correct picks earn XP when the result is in.',
      'LIVE matches show a Fan Pulse vote for quick participation XP.',
    ],
    preview: _PredictPreview(),
  );

  static const battle = HelpTopic(
    title: 'Battle Mode',
    icon: Icons.sports_kabaddi_rounded,
    intro: 'Go head-to-head with a rival in a best-of-5 quiz.',
    points: [
      'Answer faster and smarter than your opponent each round.',
      'Win to earn +100 XP and 20 trophies.',
      'Trophies rank you on the Battle leaderboard.',
    ],
    preview: _BattlePreview(),
  );

  static const club = HelpTopic(
    title: 'Fan Clubs',
    icon: Icons.groups_rounded,
    intro: 'Compete as a team, not just solo.',
    points: [
      'Global ranks every club by total XP.',
      'Country filters to your confederation.',
      'Fan Clubs ranks the members inside your own club.',
      'You are always highlighted in green.',
    ],
    preview: _FanClubPreview(),
  );

  static final collection = HelpTopic(
    title: 'Collection',
    icon: Icons.style_rounded,
    intro:
        'Cards are collectibles — teams, players and stadiums you unlock as you play.',
    points: const [
      'Three kinds: Teams, Players, Stadiums.',
      'Tap a card to flip it and see stats, history and a fun fact.',
      'How to earn cards: open Mystery Packs. You get a pack every time you level up.',
      'Four rarity tiers — Common, Rare, Epic, Legendary. The higher the rarity, the harder it is to pull from a pack.',
      'Teams: 3+ World Cup titles → Legendary (Brazil, Germany, Italy, Argentina). 1–2 titles → Epic (France, Spain, England, Uruguay). Top-10 ranked → Rare. The rest → Common.',
      'Players: 90+ overall → Legendary, 87+ → Epic, 84+ → Rare, else Common.',
      'Brazil vs Argentina? Both are Legendary, but each card has its own kit, FIFA rank, top scorer, captain, coach and fun fact — flip to compare.',
      'Use the chips on top to filter by Teams, Players or Stadiums.',
      'Greyed-out cards = still locked. They show you what to hunt for.',
    ],
    preview: _CardPreview(),
  );

  static const packs = HelpTopic(
    title: 'Mystery Packs',
    icon: Icons.card_giftcard_rounded,
    intro: 'Open packs for cards, coins and XP.',
    points: [
      'Earn a pack every time you level up.',
      'Each pack reveals cards (weighted by rarity) plus coins & XP.',
      'New cards are added straight to your Collection.',
    ],
    preview: _PackPreview(),
  );

  static const achievements = HelpTopic(
    title: 'Achievements',
    icon: Icons.emoji_events_rounded,
    intro: 'Long-term goals that reward big XP and coins.',
    points: [
      'Progress fills automatically as you play.',
      'Complete one to earn its XP + coin reward.',
      'Unlocked achievements appear as badges on your profile.',
    ],
    preview: _AchievementPreview(),
  );
}

// ---------------- Preview widgets (static samples) ----------------

class _StreakPreview extends StatelessWidget {
  const _StreakPreview();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 240,
      child: StreakDots(
          last7Days: [true, true, true, true, true, false, false]),
    );
  }
}

class _DailyGoalPreview extends StatelessWidget {
  const _DailyGoalPreview();
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('90 / 150 XP',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12)),
        SizedBox(height: 8),
        SizedBox(
            width: 220,
            child: AppProgressBar(progress: 0.6, gradient: AppColors.goldCta)),
      ],
    );
  }
}

class _FanClubPreview extends StatelessWidget {
  const _FanClubPreview();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row('1', '🇦🇷', 'Argentina Fans', '128,500', false),
        const SizedBox(height: 8),
        _row('2', '🇧🇷', 'Brazil Fans', '124,300', true),
      ],
    );
  }

  Widget _row(String rank, String flag, String name, String xp, bool you) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: you
            ? AppColors.primaryGreen.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: you
                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Text(rank,
              style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
          const SizedBox(width: 10),
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          Text(xp,
              style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _JourneyPreview extends StatelessWidget {
  const _JourneyPreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.greenCta,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learn Teams',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                SizedBox(height: 4),
                StarRow(filled: 3, size: 14),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primaryGreen, size: 22),
        ],
      ),
    );
  }
}

class _PredictPreview extends StatelessWidget {
  const _PredictPreview();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🇦🇷  vs  🇫🇷', style: TextStyle(fontSize: 26)),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn('ARG'),
            const SizedBox(width: 8),
            _btn('DRAW'),
            const SizedBox(width: 8),
            _btn('FRA'),
          ],
        ),
      ],
    );
  }

  Widget _btn(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassFillStrong,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13)),
    );
  }
}

class _BattlePreview extends StatelessWidget {
  const _BattlePreview();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _side('You', '3', AppColors.primaryGreen),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('VS',
              style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
        ),
        _side('Rival', '2', AppColors.danger),
      ],
    );
  }

  Widget _side(String name, String score, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(name,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
          Text(score,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 22)),
        ],
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview();
  @override
  Widget build(BuildContext context) {
    const card = CollectibleCard(
      id: 'team_bra',
      type: CardType.team,
      refId: 'bra',
      name: 'Brazil',
      subtitle: 'CONMEBOL',
      rarity: Rarity.legendary,
      ratingLabel: '★★★★★',
      emoji: '🇧🇷',
    );
    return SizedBox(
      width: 110,
      height: 150,
      child: CardTile(card: card, unlocked: true, onTap: () {}),
    );
  }
}

class _PackPreview extends StatelessWidget {
  const _PackPreview();
  @override
  Widget build(BuildContext context) {
    return const PackBox(width: 110);
  }
}

class _AchievementPreview extends StatelessWidget {
  const _AchievementPreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_fire_department_rounded,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Streak Master',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
                SizedBox(height: 6),
                SizedBox(width: 160, child: AppProgressBar(progress: 0.5, height: 7)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('7/14',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
