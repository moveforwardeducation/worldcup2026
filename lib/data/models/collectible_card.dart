import 'package:flutter/foundation.dart';

import 'player.dart';
import 'rarity.dart';
import 'stadium.dart';
import 'team.dart';

enum CardType { team, player, stadium }

/// A collectible card derived from a team/player/stadium. The [refId] points
/// back at the underlying seed entity so the detail screen can show full info.
@immutable
class CollectibleCard {
  const CollectibleCard({
    required this.id,
    required this.type,
    required this.refId,
    required this.name,
    required this.subtitle,
    required this.rarity,
    required this.ratingLabel,
    this.emoji,
    this.primaryColor,
    this.secondaryColor,
  });

  final String id;
  final CardType type;
  final String refId;
  final String name;
  final String subtitle;
  final Rarity rarity;

  /// Small label shown in the card corner (e.g. "93", "★★★", "82k").
  final String ratingLabel;
  final String? emoji;
  final int? primaryColor;
  final int? secondaryColor;

  // ---- Factories from seed entities ----

  factory CollectibleCard.fromTeam(Team t) {
    final Rarity rarity;
    if (t.worldCupWins >= 3) {
      rarity = Rarity.legendary;
    } else if (t.worldCupWins >= 1) {
      rarity = Rarity.epic;
    } else if ((t.fifaRanking ?? 99) <= 10) {
      rarity = Rarity.rare;
    } else {
      rarity = Rarity.common;
    }
    final stars = (5 - ((t.fifaRanking ?? 30) ~/ 8)).clamp(2, 5);
    return CollectibleCard(
      id: 'team_${t.id}',
      type: CardType.team,
      refId: t.id,
      name: t.name,
      subtitle: t.confederation,
      rarity: rarity,
      ratingLabel: '★' * stars,
      emoji: t.flagEmoji,
      primaryColor: t.primaryColor,
      secondaryColor: t.secondaryColor,
    );
  }

  factory CollectibleCard.fromPlayer(Player p, {String? teamName}) {
    final Rarity rarity;
    if (p.overall >= 90) {
      rarity = Rarity.legendary;
    } else if (p.overall >= 87) {
      rarity = Rarity.epic;
    } else if (p.overall >= 84) {
      rarity = Rarity.rare;
    } else {
      rarity = Rarity.common;
    }
    return CollectibleCard(
      id: 'player_${p.id}',
      type: CardType.player,
      refId: p.id,
      name: p.name,
      subtitle: teamName == null ? p.position : '${p.position} · $teamName',
      rarity: rarity,
      ratingLabel: '${p.overall}',
    );
  }

  factory CollectibleCard.fromStadium(Stadium s) {
    final Rarity rarity;
    if (s.capacity >= 80000) {
      rarity = Rarity.legendary;
    } else if (s.capacity >= 70000) {
      rarity = Rarity.epic;
    } else if (s.capacity >= 55000) {
      rarity = Rarity.rare;
    } else {
      rarity = Rarity.common;
    }
    return CollectibleCard(
      id: 'stadium_${s.id}',
      type: CardType.stadium,
      refId: s.id,
      name: s.name,
      subtitle: s.country,
      rarity: rarity,
      ratingLabel: '${(s.capacity / 1000).round()}k',
    );
  }
}
