import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/banner_ad_slot.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../data/providers.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../data/fan_club_models.dart';
import 'fan_club_providers.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  int _tab = 0; // 0 Clubs, 1 My Club
  bool _confederationOnly = false; // Clubs filter: All vs My Region

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(fanClubProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              bottom: false,
              child: async.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen)),
                error: (e, _) => Center(
                    child: Text('$e',
                        style:
                            const TextStyle(color: AppColors.textSecondary))),
                data: (data) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    BannerHeader(
                      title: 'Fan Clubs',
                      subtitle: 'Compete with fans worldwide',
                      showBack: false,
                      backdrop: const Confetti(),
                      action: HelpButton(topic: AppHelp.club),
                      emblem: _ClubEmblem(
                          flag: data.global
                              .firstWhere((t) => t.teamId == data.userTeamId,
                                  orElse: () => data.global.first)
                              .flag),
                    ),
                    const SizedBox(height: 6),
                    _MyClubCard(data: data),
                    const SizedBox(height: 20),
                    const Center(child: BannerAdSlot()),
                    const SizedBox(height: 20),
                    _Tabs(
                      tab: _tab,
                      onChange: (t) => setState(() => _tab = t),
                    ),
                    const SizedBox(height: 12),
                    if (_tab == 0) ...[
                      const _TabHint(
                          'Every team has a fan club. Clubs are ranked by '
                          'their fans’ total XP.'),
                      const SizedBox(height: 12),
                      _RegionToggle(
                        confederationOnly: _confederationOnly,
                        onChange: (v) =>
                            setState(() => _confederationOnly = v),
                      ),
                      const SizedBox(height: 14),
                      ..._teamRows(
                        _confederationOnly ? data.country : data.global,
                        data.userTeamId,
                        ref
                                .watch(userProfileProvider)
                                ?.followedTeamIds
                                .toSet() ??
                            const {},
                      ),
                    ] else ...[
                      const _TabHint(
                          'Your club-mates — fans who support your team, '
                          'ranked by their XP.'),
                      const SizedBox(height: 14),
                      ..._memberRows(data.members),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _teamRows(
    List<TeamStanding> teams,
    String userTeamId,
    Set<String> followed,
  ) {
    return [
      for (var i = 0; i < teams.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _LeaderRow(
            rank: i + 1,
            leading: Text(teams[i].flag, style: const TextStyle(fontSize: 24)),
            name: '${teams[i].name} Fans',
            xp: teams[i].xp,
            highlight: teams[i].teamId == userTeamId,
            followed: teams[i].teamId != userTeamId &&
                followed.contains(teams[i].teamId),
          ),
        ),
    ];
  }

  List<Widget> _memberRows(List<MemberStanding> members) {
    return [
      for (var i = 0; i < members.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _LeaderRow(
            rank: i + 1,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surfaceHigh,
              child: Text(members[i].name.characters.first,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
            name: members[i].isYou ? '${members[i].name} (You)' : members[i].name,
            xp: members[i].xp,
            highlight: members[i].isYou,
          ),
        ),
    ];
  }
}

class _MyClubCard extends StatelessWidget {
  const _MyClubCard({required this.data});
  final FanClubData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.greenCta,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Fan Club',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${data.userTeamName} Fans',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20)),
              const SizedBox(height: 4),
              Text('Global Rank #${data.userTeamRank}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatNumber(data.userTeamXp),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
              const Text('total XP',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              if (!data.backendLive)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('offline',
                      style: TextStyle(color: Colors.white60, fontSize: 10)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onChange});
  final int tab;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = ['Clubs', 'My Club'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChange(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: tab == i ? AppColors.greenCta : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: tab == i ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One-line descriptor shown under the tab bar to explain the current view.
class _TabHint extends StatelessWidget {
  const _TabHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.5,
        height: 1.35,
      ),
    );
  }
}

/// All / My Region filter for the Clubs leaderboard (replaces the old
/// "Country" tab — it was just a confederation filter of Global).
class _RegionToggle extends StatelessWidget {
  const _RegionToggle({
    required this.confederationOnly,
    required this.onChange,
  });
  final bool confederationOnly;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('All clubs', !confederationOnly, () => onChange(false), null),
        const SizedBox(width: 8),
        _pill('My region', confederationOnly, () => onChange(true),
            Icons.public_rounded),
      ],
    );
  }

  Widget _pill(String label, bool active, VoidCallback onTap, IconData? icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryGreen.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppColors.primaryGreen.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: active ? AppColors.primaryGreen : AppColors.textMuted),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(
                  color:
                      active ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({
    required this.rank,
    required this.leading,
    required this.name,
    required this.xp,
    required this.highlight,
    this.followed = false,
  });

  final int rank;
  final Widget leading;
  final String name;
  final int xp;
  final bool highlight;
  final bool followed;

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
        color: highlight
            ? AppColors.primaryGreen.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.primaryGreen.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: medal, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
                if (followed) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star_rounded,
                      color: AppColors.gold, size: 14),
                ],
              ],
            ),
          ),
          Text(
            formatNumber(xp),
            style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Text('XP',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ClubEmblem extends StatelessWidget {
  const _ClubEmblem({required this.flag});
  final String flag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: AppColors.greenCta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(flag, style: const TextStyle(fontSize: 44)),
    );
  }
}
