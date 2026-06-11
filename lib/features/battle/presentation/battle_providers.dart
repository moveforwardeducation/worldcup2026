import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
import '../data/battle_repository.dart';

final battleRepositoryProvider = Provider<BattleRepository>((ref) {
  final FirebaseFirestore? fs =
      firebaseReady ? ref.read(firestoreProvider) : null;
  return BattleRepository(
    firestore: fs,
    uid: ref.watch(authUidProvider).valueOrNull,
  );
});

class TrophiesNotifier extends StateNotifier<int> {
  TrophiesNotifier(this._repo) : super(_repo.trophies);
  final BattleRepository _repo;

  Future<void> add(int n, {required String name}) async {
    await _repo.addTrophies(n, name: name);
    state = _repo.trophies;
  }
}

final trophiesProvider = StateNotifierProvider<TrophiesNotifier, int>((ref) {
  return TrophiesNotifier(ref.read(battleRepositoryProvider));
});

final battleLeaderboardProvider = FutureProvider<List<BattleEntry>>((ref) async {
  // Re-fetch when trophies change.
  ref.watch(trophiesProvider);
  final profile = ref.watch(userProfileProvider);
  return ref
      .read(battleRepositoryProvider)
      .leaderboard(profile?.username ?? 'You');
});
