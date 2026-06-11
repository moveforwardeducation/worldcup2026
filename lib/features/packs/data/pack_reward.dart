import '../../../data/models/collectible_card.dart';

enum RewardKind { card, coins, xp }

/// A single reward revealed when opening a mystery pack.
class PackReward {
  const PackReward.card(this.card, {required this.isNew})
      : kind = RewardKind.card,
        amount = 0;

  const PackReward.coins(this.amount)
      : kind = RewardKind.coins,
        card = null,
        isNew = false;

  const PackReward.xp(this.amount)
      : kind = RewardKind.xp,
        card = null,
        isNew = false;

  final RewardKind kind;
  final CollectibleCard? card;
  final bool isNew;
  final int amount;
}
