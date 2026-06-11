import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../core/services/progression_service.dart';
import '../../../core/services/stats_repository.dart';
import '../../../data/models/fixture.dart';
import '../../../data/models/group.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
import '../data/predictions_repository.dart';

const int kPredictionXp = 50;
const int kPredictionCoins = 10;
const int kGroupXp = 75;
const int kGroupCoins = 20;

/// Demo: a match's result becomes available this long after kickoff.
const int kResolveDelayMs = 60 * 1000;
const int kDayMs = 24 * 60 * 60 * 1000;

enum PredStatus { open, locked, resolved, hidden }

/// Real schedule + results from Firestore `fixtures` (written by the sync
/// pipeline) when available; otherwise the bundled demo fixtures.
final fixturesProvider = FutureProvider<List<Fixture>>((ref) async {
  if (firebaseReady) {
    try {
      final snap =
          await ref.read(firestoreProvider).collection('fixtures').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) => Fixture.fromFirestore(d.id, d.data()))
            .toList();
      }
    } catch (_) {
      // fall back to bundled
    }
  }
  return ref.read(seedLoaderProvider).loadFixtures();
});

final groupsProvider = FutureProvider<List<GroupInfo>>((ref) async {
  return ref.read(seedLoaderProvider).loadGroups();
});

final predictionsRepositoryProvider = Provider<PredictionsRepository>((ref) {
  final FirebaseFirestore? fs =
      firebaseReady ? ref.read(firestoreProvider) : null;
  return PredictionsRepository(
    firestore: fs,
    uid: ref.watch(authUidProvider).valueOrNull,
  );
});

final predictAnchorProvider = Provider<int>((ref) {
  return ref.read(predictionsRepositoryProvider).anchorMs();
});

/// Bumped whenever predictions resolve, to refresh the UI.
final predictionRefreshProvider = StateProvider<int>((ref) => 0);

/// Map of id -> pick (covers both fixtures and groups).
class PredictionsNotifier extends StateNotifier<Map<String, int>> {
  PredictionsNotifier(this._repo) : super(_repo.readAll());
  final PredictionsRepository _repo;

  Future<void> save({required String id, required int pick}) async {
    await _repo.save(id: id, pick: pick);
    state = _repo.readAll();
  }
}

final predictionsProvider =
    StateNotifierProvider<PredictionsNotifier, Map<String, int>>((ref) {
  return PredictionsNotifier(ref.read(predictionsRepositoryProvider));
});

int fixtureKickoffMs(Fixture f, int anchor) =>
    f.kickoffMs ?? (anchor + f.kickoffInMinutes * 60000);

PredStatus fixtureStatus(Fixture f, int anchor, int now) {
  final kickoff = fixtureKickoffMs(f, anchor);

  // Real schedule/results from the feed.
  if (f.status != null) {
    if (f.status == 'finished') return PredStatus.resolved;
    if (f.status == 'in_play') return PredStatus.locked;
    if (now >= kickoff) return PredStatus.locked; // started; awaiting feed
    if (kickoff - now > kDayMs) return PredStatus.hidden;
    return PredStatus.open;
  }

  // Bundled demo: short-delay resolution off the time window.
  final resolve = kickoff + kResolveDelayMs;
  if (now >= resolve) return PredStatus.resolved;
  if (now >= kickoff) return PredStatus.locked;
  if (kickoff - now > kDayMs) return PredStatus.hidden;
  return PredStatus.open;
}

PredStatus groupStatus(GroupInfo g, int anchor, int now) {
  final conclude = anchor + g.concludeInMinutes * 60000;
  if (now >= conclude) return PredStatus.resolved;
  return PredStatus.open;
}

/// Grades any picks whose matches/groups have resolved, awarding XP once.
Future<void> resolveDuePredictions(WidgetRef ref) async {
  final repo = ref.read(predictionsRepositoryProvider);
  final anchor = repo.anchorMs();
  final now = DateTime.now().millisecondsSinceEpoch;
  final picks = ref.read(predictionsProvider);
  final graded = repo.gradedIds();
  final progression = ref.read(progressionServiceProvider);
  final stats = ref.read(statsProvider.notifier);

  final fixtures = ref.read(fixturesProvider).valueOrNull ?? const [];
  final groups = ref.read(groupsProvider).valueOrNull ?? const [];
  var changed = false;

  for (final f in fixtures) {
    if (!picks.containsKey(f.id) || graded.contains(f.id)) continue;
    if (fixtureStatus(f, anchor, now) != PredStatus.resolved) continue;
    final correct = picks[f.id] == f.result;
    if (correct) {
      progression.awardXp(kPredictionXp, coins: kPredictionCoins);
    }
    await stats.recordPrediction(correct: correct);
    await repo.markGraded(f.id);
    changed = true;
  }

  for (final g in groups) {
    if (!picks.containsKey(g.id) || graded.contains(g.id)) continue;
    if (groupStatus(g, anchor, now) != PredStatus.resolved) continue;
    final correct = picks[g.id] == g.winnerIndex;
    if (correct) {
      progression.awardXp(kGroupXp, coins: kGroupCoins);
    }
    await stats.recordPrediction(correct: correct);
    await repo.markGraded(g.id);
    changed = true;
  }

  if (changed) {
    ref.read(predictionRefreshProvider.notifier).state++;
  }
}
