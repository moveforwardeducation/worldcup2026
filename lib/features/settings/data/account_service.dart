import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../app/bootstrap.dart';
import '../../../core/services/stats_repository.dart';
import '../../../data/local/hive/hive_boxes.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
import '../../battle/presentation/battle_providers.dart';
import '../../collection/presentation/collection_providers.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../live_challenge/presentation/live_challenge_providers.dart';
import '../../onboarding/presentation/onboarding_providers.dart';
import '../../packs/presentation/packs_providers.dart';
import '../../predictions/presentation/predictions_providers.dart';

/// Deletes the user's account + all their data (Play Store compliance).
/// Best-effort on the cloud, guaranteed wipe locally, then resets in-memory
/// state so the app returns to a fresh first-run.
Future<void> deleteAccountAndData(WidgetRef ref) async {
  // 1. Remove cloud data (best-effort — never blocks the local wipe).
  if (firebaseReady) {
    try {
      final fs = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        for (final sub in const ['predictions', 'liveAnswers', 'votes']) {
          final snap =
              await fs.collection('users').doc(uid).collection(sub).get();
          for (final d in snap.docs) {
            await d.reference.delete();
          }
        }
        await fs.collection('users').doc(uid).delete();
        await fs.collection('battleLeaderboard').doc(uid).delete();
        final followed =
            ref.read(userProfileProvider)?.followedTeamIds ?? const [];
        for (final t in followed) {
          await fs
              .collection('fanClubMembers')
              .doc(t)
              .collection('members')
              .doc(uid)
              .delete();
        }
      }
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      if (kDebugMode) debugPrint('Cloud account deletion (best-effort): $e');
    }
  }

  // 2. Wipe all local data.
  for (final name in const [
    HiveBoxes.userProfile,
    HiveBoxes.xpState,
    HiveBoxes.streak,
    HiveBoxes.unlockedCards,
    HiveBoxes.completedLessons,
    HiveBoxes.predictionHistory,
    HiveBoxes.achievementProgress,
    HiveBoxes.settings,
  ]) {
    await Hive.box(name).clear();
  }

  // 3. Reset in-memory state so the UI reflects a fresh account.
  ref.invalidate(userProfileProvider);
  ref.invalidate(xpProvider);
  ref.invalidate(streakProvider);
  ref.invalidate(statsProvider);
  ref.invalidate(unlockedCardsProvider);
  ref.invalidate(packsCountProvider);
  ref.invalidate(trophiesProvider);
  ref.invalidate(predictionsProvider);
  ref.invalidate(answeredLiveProvider);
  ref.invalidate(journeyProvider);
  ref.invalidate(onboardingDoneProvider);
  ref.invalidate(authUidProvider); // re-signs in anonymously (new uid)
}
