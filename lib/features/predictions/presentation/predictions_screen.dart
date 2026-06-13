import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/country_flags.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_slot.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../data/models/fixture.dart';
import '../../../data/models/group.dart';
import '../../../data/models/team.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../../live_challenge/presentation/live_challenge_providers.dart';
import '../../live_challenge/presentation/widgets/live_challenge_card.dart';
import 'predictions_providers.dart';
import 'widgets/match_prediction_card.dart';
import 'widgets/prediction_card.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({super.key});

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen> {
  Timer? _timer;
  int _tab = 0; // 0 Live · 1 Next · 2 Groups

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePendingTab();
      _tick();
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _tick());
  }

  void _consumePendingTab() {
    final pending = ref.read(pendingPredictTabProvider);
    if (pending == null) return;
    setState(() => _tab = pending);
    ref.read(pendingPredictTabProvider.notifier).state = null;
  }

  void _tick() {
    if (!mounted) return;
    resolveDuePredictions(ref);
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pick(String id, int option) {
    final previous = ref.read(predictionsProvider)[id];
    if (previous == option) return;
    HapticFeedback.lightImpact();
    ref.read(predictionsProvider.notifier).save(id: id, pick: option);
    ref.read(voteRepositoryProvider).recordVote(
          pollId: id,
          option: option,
          previousOption: previous,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(predictionRefreshProvider);
    // Consume any pending tab request made via [pendingPredictTabProvider]
    // (e.g. from the Schedule screen) on every rebuild after the first.
    ref.listen<int?>(pendingPredictTabProvider, (_, next) {
      if (next == null) return;
      setState(() => _tab = next);
      ref.read(pendingPredictTabProvider.notifier).state = null;
    });
    final fixturesAsync = ref.watch(fixturesProvider);
    final groups = ref.watch(groupsProvider);
    final loading = fixturesAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              bottom: false,
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: BannerHeader(
                            title: 'Predictions',
                            subtitle: 'Vote, predict & earn XP',
                            showBack: false,
                            backdrop: const Confetti(),
                            emblem: const _PredictEmblem(),
                            action: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CircleIconButton(
                                  icon: Icons.calendar_month_rounded,
                                  onTap: () => context.push('/schedule'),
                                ),
                                const SizedBox(width: 8),
                                HelpButton(topic: AppHelp.predict),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                          child: _Tabs(
                            tab: _tab,
                            onChange: (t) => setState(() => _tab = t),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                            children: _tabContent(
                              fixturesAsync.valueOrNull ?? const [],
                              groups,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Center(child: BannerAdSlot()),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabContent(List<Fixture> fixtures, List<GroupInfo> groups) {
    switch (_tab) {
      case 0:
        return const [_LiveSection()];
      case 1:
        return _nextTab(fixtures);
      default:
        return _groupsTab(groups);
    }
  }

  // ---- Next Matches tab ----
  List<Widget> _nextTab(List<Fixture> fixtures) {
    final teams = ref.watch(teamsProvider).valueOrNull ?? const <Team>[];
    final teamMap = {for (final t in teams) t.id: t};
    final picks = ref.watch(predictionsProvider);
    final anchor = ref.watch(predictAnchorProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    final open = <Fixture>[];
    final locked = <Fixture>[];
    final resolved = <Fixture>[];
    for (final f in fixtures) {
      switch (fixtureStatus(f, anchor, now)) {
        case PredStatus.open:
          open.add(f);
        case PredStatus.locked:
          locked.add(f);
        case PredStatus.resolved:
          resolved.add(f);
        case PredStatus.hidden:
          break;
      }
    }
    open.sort((a, b) =>
        fixtureKickoffMs(a, anchor).compareTo(fixtureKickoffMs(b, anchor)));

    Widget card(Fixture f, PredStatus status) {
      final ko = fixtureKickoffMs(f, anchor);
      final line = switch (status) {
        PredStatus.open => 'Locks in ${_countdown(ko - now)}',
        _ => f.dateLabel,
      };
      return MatchPredictionCard(
        pollId: f.id,
        dateLabel: f.dateLabel,
        statusLine: line,
        flagA: teamMap[f.teamA]?.flagEmoji ?? flagForId(f.teamA),
        nameA: teamMap[f.teamA]?.name ?? nameForId(f.teamA),
        flagB: teamMap[f.teamB]?.flagEmoji ?? flagForId(f.teamB),
        nameB: teamMap[f.teamB]?.name ?? nameForId(f.teamB),
        scoreA: f.scoreA,
        scoreB: f.scoreB,
        status: status,
        pick: picks[f.id],
        onSelect: (o) => _pick(f.id, o),
      );
    }

    if (open.isEmpty && locked.isEmpty && resolved.isEmpty) {
      return const [
        _Empty(
          icon: Icons.event_available_rounded,
          text: 'No matches in the next 24 hours. Check back soon!',
        ),
      ];
    }

    return [
      if (open.isNotEmpty) ...[
        const _SectionLabel('OPEN TO PREDICT'),
        const SizedBox(height: 10),
        for (final f in open) ...[card(f, PredStatus.open), const SizedBox(height: 12)],
      ],
      if (locked.isNotEmpty) ...[
        const SizedBox(height: 6),
        const _SectionLabel('IN PLAY'),
        const SizedBox(height: 10),
        for (final f in locked) ...[
          card(f, PredStatus.locked),
          const SizedBox(height: 12)
        ],
      ],
      if (resolved.isNotEmpty) ...[
        const SizedBox(height: 6),
        const _SectionLabel('RESULTS'),
        const SizedBox(height: 10),
        for (final f in resolved) ...[
          card(f, PredStatus.resolved),
          const SizedBox(height: 12)
        ],
      ],
    ];
  }

  // ---- Group Matches tab ----
  List<Widget> _groupsTab(List<GroupInfo> groups) {
    final teams = ref.watch(teamsProvider).valueOrNull ?? const <Team>[];
    final teamMap = {for (final t in teams) t.id: t};
    final picks = ref.watch(predictionsProvider);
    final anchor = ref.watch(predictAnchorProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    String label(String id) =>
        '${teamMap[id]?.flagEmoji ?? flagForId(id)} '
        '${teamMap[id]?.name ?? nameForId(id)}';

    if (groups.isEmpty) {
      return const [
        _Empty(icon: Icons.groups_rounded, text: 'Groups will appear here.'),
      ];
    }

    return [
      const _SectionLabel('PREDICT THE GROUP WINNERS'),
      const SizedBox(height: 10),
      for (final g in groups) ...[
        PredictionCard(
          pollId: g.id,
          title: '${g.name} — Winner',
          statusLine: groupStatus(g, anchor, now) == PredStatus.open
              ? 'Who tops the group?'
              : 'Group decided',
          optionLabels: [for (final id in g.teamIds) label(id)],
          status: groupStatus(g, anchor, now),
          pick: picks[g.id],
          rewardText: '+$kGroupXp XP',
          correctIndex: groupStatus(g, anchor, now) == PredStatus.resolved
              ? g.winnerIndex
              : null,
          onSelect: (o) => _pick(g.id, o),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  String _countdown(int ms) {
    if (ms <= 0) return 'moments';
    final totalSec = ms ~/ 1000;
    if (totalSec >= 3600) {
      final h = totalSec ~/ 3600;
      final m = (totalSec % 3600) ~/ 60;
      return '${h}h ${m}m';
    }
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onChange});
  final int tab;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    const labels = ['Live', 'Next', 'Groups'];
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

class _LiveSection extends ConsumerWidget {
  const _LiveSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(liveMatchesProvider);
    if (matches.isEmpty) {
      return const _Empty(
        icon: Icons.podcasts_rounded,
        text:
            'No live matches right now. Live votes appear here while matches are being played.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in matches)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LiveChallengeCard(
              key: ValueKey(m.current.id),
              challenge: m.current,
            ),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textSecondary, size: 17),
        ),
      ),
    );
  }
}

class _PredictEmblem extends StatelessWidget {
  const _PredictEmblem();
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
      child: const Icon(Icons.online_prediction_rounded,
          color: Colors.white, size: 44),
    );
  }
}
