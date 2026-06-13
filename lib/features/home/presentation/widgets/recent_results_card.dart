import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/country_flags.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/fixture.dart';
import '../../../../data/models/team.dart';
import '../../../../data/providers.dart';
import '../../../predictions/presentation/predictions_providers.dart';

/// Home-screen card showing the two most recent finished matches. Tapping a
/// row opens a detail sheet; the header links through to the full Results tab.
class RecentResultsCard extends ConsumerWidget {
  const RecentResultsCard({super.key});

  static const int _matchDurationMs = 110 * 60 * 1000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.watch(fixturesProvider).valueOrNull ?? const <Fixture>[];
    final teams = ref.watch(teamsProvider).valueOrNull ?? const <Team>[];
    final teamMap = {for (final t in teams) t.id: t};
    final anchor = ref.watch(predictAnchorProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Finished fixtures, most recent first.
    final finished = fixtures.where((f) => _isFinished(f, anchor, now)).toList()
      ..sort((a, b) => fixtureKickoffMs(b, anchor)
          .compareTo(fixtureKickoffMs(a, anchor)));
    final recent = finished.take(2).toList();

    if (recent.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16234A), Color(0xFF101C3E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.scoreboard_rounded,
                  color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              const Text('Latest Results',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/schedule'),
                child: const Row(
                  children: [
                    Text('All',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final f in recent)
            _ResultRow(
              fixture: f,
              teamMap: teamMap,
              onTap: () => _showDetail(context, f, teamMap),
            ),
        ],
      ),
    );
  }

  bool _isFinished(Fixture f, int anchor, int now) {
    if (f.status == 'finished') return true;
    if (f.status != null) return false; // scheduled / in_play from feed
    // Bundled demo: finished once the match window has elapsed.
    return now >= fixtureKickoffMs(f, anchor) + _matchDurationMs;
  }

  void _showDetail(
    BuildContext context,
    Fixture f,
    Map<String, Team> teamMap,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultDetailSheet(fixture: f, teamMap: teamMap),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.fixture,
    required this.teamMap,
    required this.onTap,
  });

  final Fixture fixture;
  final Map<String, Team> teamMap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = teamMap[fixture.teamA];
    final b = teamMap[fixture.teamB];
    final aWin = fixture.scoreA > fixture.scoreB;
    final bWin = fixture.scoreB > fixture.scoreA;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: _side(
                  flag: a?.flagEmoji ?? flagForId(fixture.teamA),
                  code: a?.code ?? codeForId(fixture.teamA),
                  win: aWin,
                  alignEnd: false,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${fixture.scoreA} - ${fixture.scoreB}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15),
                ),
              ),
              Expanded(
                child: _side(
                  flag: b?.flagEmoji ?? flagForId(fixture.teamB),
                  code: b?.code ?? codeForId(fixture.teamB),
                  win: bWin,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _side({
    required String flag,
    required String code,
    required bool win,
    required bool alignEnd,
  }) {
    final children = [
      Text(flag, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 6),
      Flexible(
        child: Text(code,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: win ? AppColors.primaryGreen : AppColors.textPrimary,
                fontWeight: win ? FontWeight.w900 : FontWeight.w700,
                fontSize: 14)),
      ),
    ];
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd ? children.reversed.toList() : children,
    );
  }
}

class _ResultDetailSheet extends StatelessWidget {
  const _ResultDetailSheet({required this.fixture, required this.teamMap});

  final Fixture fixture;
  final Map<String, Team> teamMap;

  @override
  Widget build(BuildContext context) {
    final a = teamMap[fixture.teamA];
    final b = teamMap[fixture.teamB];
    final nameA = a?.name ?? nameForId(fixture.teamA);
    final nameB = b?.name ?? nameForId(fixture.teamB);
    final flagA = a?.flagEmoji ?? flagForId(fixture.teamA);
    final flagB = b?.flagEmoji ?? flagForId(fixture.teamB);
    final outcome = fixture.scoreA == fixture.scoreB
        ? 'Draw'
        : '${fixture.scoreA > fixture.scoreB ? nameA : nameB} won';
    final ko = fixture.kickoffMs;
    final when = ko != null
        ? DateFormat('EEEE, d MMM · HH:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(ko))
        : fixture.dateLabel;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('FULL TIME',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _teamColumn(flagA, nameA)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${fixture.scoreA} - ${fixture.scoreB}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 32),
                    ),
                  ),
                  Expanded(child: _teamColumn(flagB, nameB)),
                ],
              ),
              const SizedBox(height: 16),
              Text(outcome,
                  style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
              const SizedBox(height: 8),
              if (fixture.dateLabel.isNotEmpty)
                Text(fixture.dateLabel,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(when,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamColumn(String flag, String name) {
    return Column(
      children: [
        Text(flag, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
      ],
    );
  }
}
