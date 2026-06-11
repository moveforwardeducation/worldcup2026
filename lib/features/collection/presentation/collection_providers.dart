import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/collectible_card.dart';
import '../../../data/providers.dart';
import '../data/collection_repository.dart';

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository();
});

/// Full catalogue of every collectible card, built from the seed entities.
final cardCatalogProvider = FutureProvider<List<CollectibleCard>>((ref) async {
  final teams = await ref.watch(teamsProvider.future);
  final players = await ref.watch(playersProvider.future);
  final stadiums = await ref.watch(stadiumsProvider.future);

  final teamNames = {for (final t in teams) t.id: t.name};

  return [
    ...teams.map(CollectibleCard.fromTeam),
    ...players.map((p) =>
        CollectibleCard.fromPlayer(p, teamName: teamNames[p.teamId])),
    ...stadiums.map(CollectibleCard.fromStadium),
  ];
});

/// Mutable set of unlocked card ids. Call [unlock] then the UI rebuilds.
class UnlockedCardsNotifier extends StateNotifier<Set<String>> {
  UnlockedCardsNotifier(this._repo) : super(_repo.unlockedIds());
  final CollectionRepository _repo;

  Future<bool> unlock(String id) async {
    final isNew = await _repo.unlock(id);
    if (isNew) state = _repo.unlockedIds();
    return isNew;
  }

  void refresh() => state = _repo.unlockedIds();
}

final unlockedCardsProvider =
    StateNotifierProvider<UnlockedCardsNotifier, Set<String>>((ref) {
  return UnlockedCardsNotifier(ref.read(collectionRepositoryProvider));
});

final collectionCountProvider = Provider<int>((ref) {
  return ref.watch(unlockedCardsProvider).length;
});
