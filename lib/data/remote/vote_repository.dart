import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Best-effort writer for community vote counters. Display percentages come
/// from local base counts (VoteMath); this persists the real tally to
/// Firestore `polls/{pollId}` for production aggregation across users.
class VoteRepository {
  VoteRepository({this.firestore, this.uid});

  final FirebaseFirestore? firestore;
  final String? uid;

  Future<void> recordVote({
    required String pollId,
    required int option,
    int? previousOption,
  }) async {
    final fs = firestore;
    final u = uid;
    if (fs == null || u == null) return;
    try {
      final doc = fs.collection('polls').doc(pollId);
      final update = <String, Object>{
        'opt_$option': FieldValue.increment(1),
      };
      if (previousOption != null && previousOption != option) {
        update['opt_$previousOption'] = FieldValue.increment(-1);
      }
      await doc.set(update, SetOptions(merge: true));
      await fs
          .collection('users')
          .doc(u)
          .collection('votes')
          .doc(pollId)
          .set({'option': option, 'ts': FieldValue.serverTimestamp()});
    } catch (e) {
      if (kDebugMode) debugPrint('Vote sync failed: $e');
    }
  }
}

VoteRepository buildVoteRepository(FirebaseFirestore? fs, String? uid) =>
    VoteRepository(firestore: fs, uid: uid);
