import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/hive/user_state_repository.dart';
import 'models/player.dart';
import 'models/stadium.dart';
import 'models/streak.dart';
import 'models/team.dart';
import 'models/team_jersey.dart';
import 'models/user_profile.dart';
import 'models/xp_state.dart';
import 'seed/seed_loader.dart';
import 'seed/user_state_seeder.dart';

// --- Repositories ---

final userStateRepositoryProvider = Provider<UserStateRepository>((ref) {
  return UserStateRepository();
});

final seedLoaderProvider = Provider<SeedLoader>((ref) => SeedLoader());

final userStateSeederProvider = Provider<UserStateSeeder>((ref) {
  return UserStateSeeder();
});

// --- Static seed (one-shot async) ---

final teamsProvider = FutureProvider<List<Team>>((ref) async {
  return ref.read(seedLoaderProvider).loadTeams();
});

final playersProvider = FutureProvider<List<Player>>((ref) async {
  return ref.read(seedLoaderProvider).loadPlayers();
});

final stadiumsProvider = FutureProvider<List<Stadium>>((ref) async {
  return ref.read(seedLoaderProvider).loadStadiums();
});

/// Jersey specs keyed by FIFA code (e.g. "ARG").
final jerseysByCodeProvider =
    FutureProvider<Map<String, TeamJersey>>((ref) async {
  final list = await ref.read(seedLoaderProvider).loadJerseys();
  return {for (final j in list) j.fifaCode: j};
});

final teamByIdProvider = Provider.family<Team?, String>((ref, id) {
  final teams = ref.watch(teamsProvider).valueOrNull;
  if (teams == null) return null;
  for (final t in teams) {
    if (t.id == id) return t;
  }
  return null;
});

// --- Mutable user state (StateNotifiers) ---

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier(this._repo) : super(_repo.readProfile());
  final UserStateRepository _repo;

  Future<void> save(UserProfile profile) async {
    await _repo.writeProfile(profile);
    state = profile;
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref.read(userStateRepositoryProvider));
});

class XpNotifier extends StateNotifier<XpState> {
  XpNotifier(this._repo) : super(_repo.readXp());
  final UserStateRepository _repo;

  Future<void> set(XpState next) async {
    await _repo.writeXp(next);
    state = next;
  }
}

final xpProvider = StateNotifierProvider<XpNotifier, XpState>((ref) {
  return XpNotifier(ref.read(userStateRepositoryProvider));
});

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier(this._repo) : super(_repo.readStreak());
  final UserStateRepository _repo;

  Future<void> set(StreakState next) async {
    await _repo.writeStreak(next);
    state = next;
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(ref.read(userStateRepositoryProvider));
});
