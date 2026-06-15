import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../core/constants/country_flags.dart';
import '../../../data/models/fixture.dart';
import '../../../data/models/live_challenge.dart';
import '../../../data/models/team.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
import '../../predictions/presentation/predictions_providers.dart';
import '../data/live_challenge_repository.dart';

final liveChallengesProvider =
    FutureProvider<List<LiveChallenge>>((ref) async {
  return ref.read(seedLoaderProvider).loadLiveChallenges();
});

final liveChallengeRepositoryProvider =
    Provider<LiveChallengeRepository>((ref) {
  final FirebaseFirestore? fs =
      firebaseReady ? ref.read(firestoreProvider) : null;
  return LiveChallengeRepository(
    firestore: fs,
    uid: ref.watch(authUidProvider).valueOrNull,
  );
});

/// Which live moments the user has answered, and their pick per moment
/// (0 = YES, 1 = NO) so answered moments can be shown read-only.
class LiveAnswerState {
  const LiveAnswerState(this.answered, this.choices);
  final Set<String> answered;
  final Map<String, int> choices;

  bool isAnswered(String id) => answered.contains(id);
  int? choiceFor(String id) => choices[id];
}

class AnsweredLiveNotifier extends StateNotifier<LiveAnswerState> {
  AnsweredLiveNotifier(this._repo)
      : super(LiveAnswerState(_repo.answered(), _repo.choices()));
  final LiveChallengeRepository _repo;

  Future<void> mark({
    required String id,
    required bool answeredYes,
    required bool correct,
  }) async {
    await _repo.markAnswered(id: id, answeredYes: answeredYes, correct: correct);
    state = LiveAnswerState(_repo.answered(), _repo.choices());
  }
}

final answeredLiveProvider =
    StateNotifierProvider<AnsweredLiveNotifier, LiveAnswerState>((ref) {
  return AnsweredLiveNotifier(ref.read(liveChallengeRepositoryProvider));
});

/// A match that is currently in-play, with all of its Fan-Pulse moments
/// (answered ones are rendered read-only by the card).
class LiveMatch {
  const LiveMatch({
    required this.matchId,
    required this.matchLabel,
    required this.teamId,
    required this.moments,
  });

  final String matchId;
  final String matchLabel;
  final String teamId;
  final List<LiveChallenge> moments;
}

/// Only the matches that are live *right now*, each with its unanswered
/// moments. Empty most of the time — exactly like real match data.
///
/// Prefers real Firestore `fixtures` with `status == 'in_play'` (written by
/// the sync pipeline). Synthesizes a small set of YES/NO community moments
/// per live match. Falls back to bundled demo only when Firestore returned
/// no fixtures at all (offline / pipeline not yet run).
final liveMatchesProvider = Provider<List<LiveMatch>>((ref) {
  final fixtures = ref.watch(fixturesProvider).valueOrNull ?? const <Fixture>[];
  final teams = ref.watch(teamsProvider).valueOrNull ?? const <Team>[];
  final teamMap = {for (final t in teams) t.id: t};
  final now = DateTime.now().millisecondsSinceEpoch;

  // A live match stays listed for as long as it's in-play — all of its
  // moments are kept (answered ones are shown read-only by the card), so the
  // match doesn't vanish just because you've voted on every moment.

  // Real path: any fixture carrying a status field came from Firestore.
  final fromFeed = fixtures.any((f) => f.status != null);
  if (fromFeed) {
    final result = <LiveMatch>[];
    for (final f in fixtures) {
      if (!_isLiveNow(f, now)) continue;
      final moments = _synthesizeLiveMoments(
        f,
        teamMap[f.teamA],
        teamMap[f.teamB],
        now,
      );
      if (moments.isEmpty) continue;
      result.add(LiveMatch(
        matchId: f.id,
        matchLabel: moments.first.matchLabel,
        teamId: f.teamA,
        moments: moments,
      ));
    }
    return result;
  }

  // Fallback: bundled demo (Firestore unreachable / empty).
  final all = ref.watch(liveChallengesProvider).valueOrNull ?? const [];
  final byMatch = <String, List<LiveChallenge>>{};
  for (final c in all) {
    if (!c.isLive) continue; // only in-play matches
    byMatch.putIfAbsent(c.matchId, () => []).add(c);
  }

  return [
    for (final entry in byMatch.entries)
      LiveMatch(
        matchId: entry.key,
        matchLabel: entry.value.first.matchLabel,
        teamId: entry.value.first.teamId,
        moments: entry.value,
      ),
  ];
});

/// Approximate match length used to keep a kicked-off fixture "live" while the
/// results feed catches up to mark it `in_play` / `finished`. Matches the
/// Schedule screen's live window so both views agree.
const int _kLiveWindowMs = 130 * 60 * 1000; // 130 min (covers ET + stoppage)

/// True if a fixture should be treated as live right now. Mirrors the Schedule
/// screen: `in_play` is always live; a `scheduled` fixture is live once its
/// kickoff has passed (feed lag) until the live window elapses. `finished`
/// is never live.
bool _isLiveNow(Fixture f, int now) {
  if (f.status == 'finished') return false;
  if (f.status == 'in_play') return true;
  final ko = f.kickoffMs;
  if (ko == null) return false;
  return now >= ko && now < ko + _kLiveWindowMs;
}

/// Generic YES/NO community moments derived from a real in-play fixture.
/// These are sentiment polls (+5 XP to vote, no grading), so the [answerYes]
/// field is cosmetic.
List<LiveChallenge> _synthesizeLiveMoments(
  Fixture f,
  Team? a,
  Team? b,
  int now,
) {
  final nameA = a?.name ?? nameForId(f.teamA);
  final nameB = b?.name ?? nameForId(f.teamB);
  final label = '$nameA vs $nameB';

  // Approximate match minute from kickoff (clamped to 0–120').
  final ko = f.kickoffMs ?? now;
  final minutesIn = ((now - ko) ~/ 60000).clamp(0, 120);
  final minuteLabel = "$minutesIn'";

  LiveChallenge moment(String slug, String question, bool yes) => LiveChallenge(
        id: 'lc_${f.id}_$slug',
        matchId: f.id,
        matchLabel: label,
        minute: minuteLabel,
        teamId: f.teamA,
        question: question,
        answerYes: yes,
        xp: 5,
        startsInMinutes: -minutesIn,
        durationMinutes: 120,
      );

  return [
    moment('win_a', 'Will $nameA win this match?', true),
    moment('draw', 'Will this match end in a draw?', false),
    moment('goals3', 'Will this match have 3+ total goals?', true),
    moment('next_goal_a', 'Will $nameA score the next goal?', true),
  ];
}
