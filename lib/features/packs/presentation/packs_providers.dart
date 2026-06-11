import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/progression_service.dart';
import '../../../data/models/collectible_card.dart';
import '../../../data/models/rarity.dart';
import '../../collection/presentation/collection_providers.dart';
import '../data/pack_reward.dart';
import '../data/packs_repository.dart';

final packsRepositoryProvider = Provider<PacksRepository>((ref) {
  return PacksRepository();
});

class PacksNotifier extends StateNotifier<int> {
  PacksNotifier(this._repo) : super(_repo.count);
  final PacksRepository _repo;

  Future<void> add(int n) async {
    await _repo.add(n);
    state = _repo.count;
  }

  Future<bool> consumeOne() async {
    final ok = await _repo.consumeOne();
    state = _repo.count;
    return ok;
  }
}

final packsCountProvider = StateNotifierProvider<PacksNotifier, int>((ref) {
  return PacksNotifier(ref.read(packsRepositoryProvider));
});

/// Opens one pack (if available), applies all side effects (unlock cards,
/// award coins/XP) and returns the revealed rewards for display.
Future<List<PackReward>?> openMysteryPack(WidgetRef ref) async {
  final consumed = await ref.read(packsCountProvider.notifier).consumeOne();
  if (!consumed) return null;

  final catalog = ref.read(cardCatalogProvider).valueOrNull ?? const [];
  final unlockedNotifier = ref.read(unlockedCardsProvider.notifier);
  var owned = ref.read(unlockedCardsProvider);
  final rnd = math.Random();

  final rewards = <PackReward>[];

  // Two card slots, preferring cards the user doesn't own yet.
  for (var slot = 0; slot < 2; slot++) {
    final locked = catalog.where((c) => !owned.contains(c.id)).toList();
    if (locked.isEmpty) {
      // Collection complete — convert to coins.
      rewards.add(PackReward.coins(100 + rnd.nextInt(100)));
      continue;
    }
    final picked = _weightedPick(locked, rnd);
    final isNew = await unlockedNotifier.unlock(picked.id);
    owned = ref.read(unlockedCardsProvider);
    rewards.add(PackReward.card(picked, isNew: isNew));
  }

  // Guaranteed coin + XP rewards.
  final coins = 50 + rnd.nextInt(100);
  final xp = 20 + rnd.nextInt(40);
  rewards
    ..add(PackReward.coins(coins))
    ..add(PackReward.xp(xp));

  ref.read(progressionServiceProvider).awardXp(xp, coins: coins);

  rewards.shuffle(rnd);
  return rewards;
}

CollectibleCard _weightedPick(List<CollectibleCard> pool, math.Random rnd) {
  final total = pool.fold<int>(0, (s, c) => s + c.rarity.dropWeight);
  var roll = rnd.nextInt(total);
  for (final c in pool) {
    roll -= c.rarity.dropWeight;
    if (roll < 0) return c;
  }
  return pool.last;
}
