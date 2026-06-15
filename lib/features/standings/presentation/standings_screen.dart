import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/country_flags.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../data/models/team.dart';
import '../../../data/providers.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../domain/standings_builder.dart';
import 'standings_providers.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(standingsProvider);
    final teams = ref.watch(teamsProvider).valueOrNull ?? const <Team>[];
    final teamMap = {for (final t in teams) t.id: t};
    final followed =
        ref.watch(userProfileProvider)?.followedTeamIds.toSet() ?? const {};

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: BannerHeader(
                      title: 'Standings',
                      subtitle: 'Group tables',
                      backdrop: Confetti(),
                      emblem: _TableEmblem(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (groups.isEmpty)
                    const _Empty()
                  else ...[
                    for (final g in groups) ...[
                      _GroupTable(
                        group: g,
                        teamMap: teamMap,
                        followed: followed,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _Legend(),
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

class _GroupTable extends StatelessWidget {
  const _GroupTable({
    required this.group,
    required this.teamMap,
    required this.followed,
  });

  final GroupStanding group;
  final Map<String, Team> teamMap;
  final Set<String> followed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Text(group.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
              ],
            ),
          ),
          const _HeaderRow(),
          for (var i = 0; i < group.rows.length; i++)
            _TeamRow(
              pos: i + 1,
              row: group.rows[i],
              team: teamMap[group.rows[i].teamId],
              followed: followed.contains(group.rows[i].teamId),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w800,
        fontSize: 11);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: const [
          SizedBox(width: 22, child: Text('#', style: style)),
          Expanded(child: Text('Team', style: style)),
          _Cell('P', style),
          _Cell('W', style),
          _Cell('D', style),
          _Cell('L', style),
          _Cell('GD', style, width: 30),
          _Cell('Pts', style, width: 32),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.pos,
    required this.row,
    required this.team,
    required this.followed,
  });

  final int pos;
  final StandingRow row;
  final Team? team;
  final bool followed;

  @override
  Widget build(BuildContext context) {
    // Qualification bands (48-team format): top 2 advance, 3rd may advance.
    final qualColor = pos <= 2
        ? AppColors.primaryGreen
        : (pos == 3 ? AppColors.gold : Colors.transparent);
    final flag = team?.flagEmoji ?? flagForId(row.teamId);
    final code = team?.code ?? codeForId(row.teamId);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: BoxDecoration(
        color: followed
            ? AppColors.primaryGreen.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: qualColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text('$pos',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5)),
                ),
              ],
            ),
          ),
          _Cell('${row.played}', _data),
          _Cell('${row.won}', _data),
          _Cell('${row.drawn}', _data),
          _Cell('${row.lost}', _data),
          _Cell(_signed(row.goalDiff), _data, width: 30),
          _Cell('${row.points}', _bold, width: 32),
        ],
      ),
    );
  }

  static String _signed(int v) => v > 0 ? '+$v' : '$v';

  static const _data = TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
      fontSize: 13);
  static const _bold = TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w900,
      fontSize: 13.5);
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, this.style, {this.width = 24});
  final String text;
  final TextStyle style;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          _dot(AppColors.primaryGreen),
          const SizedBox(width: 6),
          const Text('Advance',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 18),
          _dot(AppColors.gold),
          const SizedBox(width: 6),
          const Flexible(
            child: Text('3rd — may advance',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Row(
        children: [
          Icon(Icons.table_chart_rounded, color: AppColors.textMuted, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Group standings will appear here once the group-stage fixtures '
              'are available.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableEmblem extends StatelessWidget {
  const _TableEmblem();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
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
      child: const Icon(Icons.format_list_numbered_rounded,
          color: Colors.white, size: 44),
    );
  }
}
