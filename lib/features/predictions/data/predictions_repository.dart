import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';

/// Stores prediction picks (match + group) locally and mirrors them to
/// Firestore `users/{uid}/predictions/{id}`. Grading happens later via the
/// resolver, not at pick time.
class PredictionsRepository {
  PredictionsRepository({this.firestore, this.uid});

  final FirebaseFirestore? firestore;
  final String? uid;

  Box get _box => Hive.box(HiveBoxes.predictionHistory);
  Box get _settings => Hive.box(HiveBoxes.settings);

  Map<String, int> readAll() {
    final out = <String, int>{};
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v is int) out[key.toString()] = v;
    }
    return out;
  }

  int? pickFor(String id) => _box.get(id) as int?;

  Future<void> save({required String id, required int pick}) async {
    await _box.put(id, pick);
    final fs = firestore;
    final u = uid;
    if (fs != null && u != null) {
      try {
        await fs
            .collection('users')
            .doc(u)
            .collection('predictions')
            .doc(id)
            .set({'pick': pick, 'ts': FieldValue.serverTimestamp()});
      } catch (e) {
        if (kDebugMode) debugPrint('Prediction cloud sync failed: $e');
      }
    }
  }

  // ---- Grading bookkeeping ----

  Set<String> gradedIds() =>
      ((_settings.get('predictionGraded') as List?)?.cast<String>() ??
              const [])
          .toSet();

  Future<void> markGraded(String id) async {
    final set = gradedIds()..add(id);
    await _settings.put('predictionGraded', set.toList());
  }

  // ---- Demo time anchor (so kickoffs progress through a session) ----

  int anchorMs() {
    var a = _settings.get('predictAnchorMs') as int?;
    if (a == null) {
      a = DateTime.now().millisecondsSinceEpoch;
      _settings.put('predictAnchorMs', a);
    }
    return a;
  }
}
