import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';

/// Tracks how many unopened mystery packs the user owns.
class PacksRepository {
  Box get _box => Hive.box(HiveBoxes.settings);

  int get count => (_box.get('packs') as int?) ?? 0;

  Future<void> add(int n) async => _box.put('packs', count + n);

  Future<bool> consumeOne() async {
    if (count <= 0) return false;
    await _box.put('packs', count - 1);
    return true;
  }
}
