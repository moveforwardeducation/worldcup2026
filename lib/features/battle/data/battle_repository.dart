import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';

class BattleEntry {
  const BattleEntry({
    required this.name,
    required this.trophies,
    required this.isYou,
  });
  final String name;
  final int trophies;
  final bool isYou;
}

/// Battle trophies live in Hive and mirror to Firestore `battleLeaderboard`.
class BattleRepository {
  BattleRepository({this.firestore, this.uid});

  final FirebaseFirestore? firestore;
  final String? uid;

  Box get _box => Hive.box(HiveBoxes.settings);

  int get trophies => (_box.get('trophies') as int?) ?? 0;

  Future<void> addTrophies(int n, {required String name}) async {
    await _box.put('trophies', trophies + n);
    final fs = firestore;
    final u = uid;
    if (fs != null && u != null) {
      try {
        await fs
            .collection('battleLeaderboard')
            .doc(u)
            .set({'name': name, 'trophies': trophies});
      } catch (e) {
        if (kDebugMode) debugPrint('Battle sync failed: $e');
      }
    }
  }

  /// Leaderboard = real Firestore entries blended with fillers so the board
  /// stays populated until there are enough real players.
  Future<List<BattleEntry>> leaderboard(String username) async {
    final you = trophies;
    final uid = this.uid;
    final list = <BattleEntry>[];
    var haveYou = false;

    final fs = firestore;
    if (fs != null) {
      try {
        final snap = await fs
            .collection('battleLeaderboard')
            .orderBy('trophies', descending: true)
            .limit(20)
            .get();
        for (final d in snap.docs) {
          final data = d.data();
          final isYou = d.id == uid;
          if (isYou) haveYou = true;
          list.add(BattleEntry(
            name: (data['name'] as String?) ?? 'Player',
            trophies: (data['trophies'] as num?)?.toInt() ?? 0,
            isYou: isYou,
          ));
        }
      } catch (_) {
        // fall through to fillers
      }
    }
    if (!haveYou) {
      list.add(BattleEntry(name: username, trophies: you, isYou: true));
    }

    const names = ['Rahul', 'Sofia', 'Chen', 'Diego', 'Amara', 'Yuki'];
    const factors = [1.8, 1.4, 1.1, 0.8, 0.6, 0.4];
    final existing = list.map((e) => e.name).toSet();
    for (var i = 0; i < names.length && list.length < 8; i++) {
      if (existing.contains(names[i])) continue;
      list.add(BattleEntry(
        name: names[i],
        trophies: (you * factors[i]).round() + (60 - i * 8),
        isYou: false,
      ));
    }

    list.sort((a, b) => b.trophies.compareTo(a.trophies));
    return list;
  }
}
