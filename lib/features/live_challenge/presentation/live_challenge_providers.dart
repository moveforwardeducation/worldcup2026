import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../data/models/live_challenge.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
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

class AnsweredLiveNotifier extends StateNotifier<Set<String>> {
  AnsweredLiveNotifier(this._repo) : super(_repo.answered());
  final LiveChallengeRepository _repo;

  Future<void> mark({
    required String id,
    required bool answeredYes,
    required bool correct,
  }) async {
    await _repo.markAnswered(id: id, answeredYes: answeredYes, correct: correct);
    state = _repo.answered();
  }
}

final answeredLiveProvider =
    StateNotifierProvider<AnsweredLiveNotifier, Set<String>>((ref) {
  return AnsweredLiveNotifier(ref.read(liveChallengeRepositoryProvider));
});

/// A match that is currently in-play, with its remaining (unanswered) moments.
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

  LiveChallenge get current => moments.first;
}

/// Only the matches that are live *right now*, each with its unanswered
/// moments. Empty most of the time — exactly like real match data.
final liveMatchesProvider = Provider<List<LiveMatch>>((ref) {
  final all = ref.watch(liveChallengesProvider).valueOrNull ?? const [];
  final answered = ref.watch(answeredLiveProvider);

  final byMatch = <String, List<LiveChallenge>>{};
  for (final c in all) {
    if (!c.isLive) continue; // only in-play matches
    if (answered.contains(c.id)) continue; // skip moments already answered
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
