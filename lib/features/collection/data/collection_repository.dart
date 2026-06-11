import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';

/// Tracks which collectible cards the user has unlocked (by card id).
class CollectionRepository {
  Box get _box => Hive.box(HiveBoxes.unlockedCards);

  bool isUnlocked(String cardId) => _box.get(cardId) == true;

  Set<String> unlockedIds() => _box.keys
      .where((k) => _box.get(k) == true)
      .map((k) => k.toString())
      .toSet();

  int get unlockedCount => unlockedIds().length;

  /// Returns true if this was a *new* unlock (false if already owned).
  Future<bool> unlock(String cardId) async {
    if (isUnlocked(cardId)) return false;
    await _box.put(cardId, true);
    return true;
  }
}
