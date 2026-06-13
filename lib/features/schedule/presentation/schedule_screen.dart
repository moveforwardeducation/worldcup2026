import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/country_flags.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../data/models/fixture.dart';
import '../../../data/models/team.dart';
import '../../../data/providers.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../../predictions/presentation/predictions_providers.dart';

enum _SchedStatus { upcoming, live, finished }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _tab = 0; // 0 = Fixtures, 1 = Results
  bool _mine = false; // scope: All vs My Teams

  static const int _matchDurationMs = 110 * 60 * 1000;

  @override
  Widget build(BuildContext context) {
    final fixturesAsync = ref.watch(fixturesProvider);
    final teams = ref.watch(teamsProvider).valueOrNull ?? const <Team>[];
    final teamMap = {for (final t in teams) t.id: t};
    final followed =
        ref.watch(userProfileProvider)?.followedTeamIds.toSet() ?? const {};
    final anchor = ref.watch(predictAnchorProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: fixturesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen)),
                error: (e, _) => Center(
                    child: Text('$e',
                        style:
                            const TextStyle(color: AppColors.textSecondary))),
                data: (fixtures) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: BannerHeader(
                          title: 'Schedule',
                          subtitle: 'Fixtures & results',
                          backdrop: const Confetti(),
                          emblem: const _CalendarEmblem(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                        child: _SegTabs(
                          labels: const ['Fixtures', 'Results'],
                          index: _tab,
                          onChange: (t) => setState(() => _tab = t),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                        child: _ScopeToggle(
                          mine: _mine,
                          onChange: (m) => setState(() => _mine = m),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                          children:
                              _content(fixtures, teamMap, followed, anchor, now),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _SchedStatus _status(Fixture f, int anchor, int now) {
    // Real feed status takes precedence over the demo time window.
    if (f.status == 'finished') return _SchedStatus.finished;
    if (f.status == 'in_play') return _SchedStatus.live;
    final ko = fixtureKickoffMs(f, anchor);
    if (f.status == 'scheduled') {
      return now >= ko ? _SchedStatus.live : _SchedStatus.upcoming;
    }
    if (now >= ko + _matchDurationMs) return _SchedStatus.finished;
    if (now >= ko) return _SchedStatus.live;
    return _SchedStatus.upcoming;
  }

  List<Widget> _content(
    List<Fixture> fixtures,
    Map<String, Team> teamMap,
    Set<String> followed,
    int anchor,
    int now,
  ) {
    // Scope filter.
    var pool = fixtures;
    if (_mine) {
      pool = fixtures
          .where((f) =>
              followed.contains(f.teamA) || followed.contains(f.teamB))
          .toList();
    }

    final fixturesTab = _tab == 0;
    final items = pool
        .where((f) => fixturesTab
            ? _status(f, anchor, now) != _SchedStatus.finished
            : _status(f, anchor, now) == _SchedStatus.finished)
        .toList();

    // Fixtures: soonest first. Results: most recent first.
    items.sort((a, b) {
      final ka = fixtureKickoffMs(a, anchor);
      final kb = fixtureKickoffMs(b, anchor);
      return fixturesTab ? ka.compareTo(kb) : kb.compareTo(ka);
    });

    if (items.isEmpty) {
      final what = fixturesTab ? 'fixtures' : 'results';
      final who = _mine ? ' for your teams' : '';
      return [_Empty(text: 'No $what$who yet.')];
    }

    final widgets = <Widget>[];
    String? lastDay;
    for (final f in items) {
      final ko = fixtureKickoffMs(f, anchor);
      final day = _dayLabel(ko);
      if (day != lastDay) {
        lastDay = day;
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 8),
          child: Text(day,
              style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5)),
        ));
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _MatchRow(
          fixture: f,
          teamMap: teamMap,
          status: _status(f, anchor, now),
          kickoffMs: ko,
          mine: followed.contains(f.teamA) || followed.contains(f.teamB),
          predStatus: fixtureStatus(f, anchor, now),
        ),
      ));
    }
    return widgets;
  }

  String _dayLabel(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final dDay = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = dDay.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return DateFormat('EEEE, d MMM').format(d);
  }
}

class _MatchRow extends ConsumerWidget {
  const _MatchRow({
    required this.fixture,
    required this.teamMap,
    required this.status,
    required this.kickoffMs,
    required this.mine,
    required this.predStatus,
  });

  final Fixture fixture;
  final Map<String, Team> teamMap;
  final _SchedStatus status;
  final int kickoffMs;
  final bool mine;
  final PredStatus predStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = teamMap[fixture.teamA];
    final b = teamMap[fixture.teamB];
    final finished = status == _SchedStatus.finished;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: mine
            ? AppColors.primaryGreen.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mine
              ? AppColors.primaryGreen.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 52, child: _statusLeading()),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a?.flagEmoji ?? flagForId(fixture.teamA),
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(a?.code ?? codeForId(fixture.teamA),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      finished ? '${fixture.scoreA} - ${fixture.scoreB}' : 'vs',
                      style: TextStyle(
                          color: finished
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(b?.code ?? codeForId(fixture.teamB),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(b?.flagEmoji ?? flagForId(fixture.teamB),
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(fixture.dateLabel,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          if (mine)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child:
                  Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
            ),
          _predictAction(context, ref),
        ],
      ),
    );
  }

  Widget _predictAction(BuildContext context, WidgetRef ref) {
    // Live: jump to Live tab. Open (kickoff <24h): jump to Next tab.
    // Locked/resolved/hidden: no button.
    final isLive = status == _SchedStatus.live;
    if (isLive) {
      return _PredictPill(
        label: 'Vote Live',
        icon: Icons.podcasts_rounded,
        color: AppColors.info,
        onTap: () {
          ref.read(pendingPredictTabProvider.notifier).state = 0;
          context.go('/predict');
        },
      );
    }
    if (predStatus == PredStatus.open) {
      return _PredictPill(
        label: 'Predict',
        icon: Icons.online_prediction_rounded,
        color: AppColors.primaryGreen,
        onTap: () {
          ref.read(pendingPredictTabProvider.notifier).state = 1;
          context.go('/predict');
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _statusLeading() {
    switch (status) {
      case _SchedStatus.live:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text('LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10)),
        );
      case _SchedStatus.finished:
        return const Text('FT',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w900,
                fontSize: 13));
      case _SchedStatus.upcoming:
        return Text(
          DateFormat('HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(kickoffMs)),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w800,
              fontSize: 13),
        );
    }
  }
}

class _PredictPill extends StatelessWidget {
  const _PredictPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 5),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegTabs extends StatelessWidget {
  const _SegTabs({
    required this.labels,
    required this.index,
    required this.onChange,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
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
                    gradient: index == i ? AppColors.greenCta : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(labels[i],
                      style: TextStyle(
                        color: index == i
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({required this.mine, required this.onChange});
  final bool mine;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('All', !mine, () => onChange(false), null),
        const SizedBox(width: 8),
        _pill('My Teams', mine, () => onChange(true), Icons.star_rounded),
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
                  color: active ? AppColors.gold : AppColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                  color: active ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
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
          const Icon(Icons.event_busy_rounded,
              color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _CalendarEmblem extends StatelessWidget {
  const _CalendarEmblem();
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
      child: const Icon(Icons.calendar_month_rounded,
          color: Colors.white, size: 44),
    );
  }
}
