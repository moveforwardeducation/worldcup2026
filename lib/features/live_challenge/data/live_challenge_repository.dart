import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';

/// Tracks which live challenges have been answered (local + Firestore mirror).
class LiveChallengeRepository {
  LiveChallengeRepository({this.firestore, this.uid});

  final FirebaseFirestore? firestore;
  final String? uid;

  Box get _box => Hive.box(HiveBoxes.settings);

  Set<String> answered() =>
      ((_box.get('liveAnswered') as List?)?.cast<String>() ?? const [])
          .toSet();

  Future<void> markAnswered({
    required String id,
    required bool answeredYes,
    required bool correct,
  }) async {
    final set = answered()..add(id);
    await _box.put('liveAnswered', set.toList());

    final fs = firestore;
    final u = uid;
    if (fs != null && u != null) {
      try {
        await fs
            .collection('users')
            .doc(u)
            .collection('liveAnswers')
            .doc(id)
            .set({
          'answeredYes': answeredYes,
          'correct': correct,
          'ts': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (kDebugMode) debugPrint('Live answer sync failed: $e');
      }
    }
  }
}
