import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import 'vote_repository.dart';

/// Firebase Auth instance (only valid when [firebaseReady]).
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Cloud Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Ensures the user is signed in anonymously. Returns the uid, or null if
/// Firebase isn't available / sign-in failed (app keeps working offline).
final authUidProvider = FutureProvider<String?>((ref) async {
  if (!firebaseReady) return null;
  try {
    final auth = ref.read(firebaseAuthProvider);
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    return auth.currentUser?.uid;
  } catch (e) {
    if (kDebugMode) debugPrint('Anonymous sign-in failed: $e');
    return null;
  }
});

/// Convenience: whether the backend is usable this session.
final backendAvailableProvider = Provider<bool>((ref) {
  if (!firebaseReady) return false;
  return ref.watch(authUidProvider).valueOrNull != null;
});

/// Firebase Analytics (auto-collects sessions; use for custom events).
final analyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

/// Live community-vote tallies for a poll, read from Firestore `polls/{id}`
/// (keys `opt_0`, `opt_1`, …). Empty when offline.
final pollCountsProvider =
    FutureProvider.family<Map<int, int>, String>((ref, pollId) async {
  if (!firebaseReady) return const {};
  try {
    final doc =
        await ref.read(firestoreProvider).collection('polls').doc(pollId).get();
    final data = doc.data();
    if (data == null) return const {};
    final out = <int, int>{};
    data.forEach((k, v) {
      if (k.startsWith('opt_') && v is num) {
        final i = int.tryParse(k.substring(4));
        if (i != null) out[i] = v.toInt();
      }
    });
    return out;
  } catch (_) {
    return const {};
  }
});

/// Best-effort community-vote writer (Firestore `polls`).
final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  final FirebaseFirestore? fs =
      firebaseReady ? ref.read(firestoreProvider) : null;
  return VoteRepository(
      firestore: fs, uid: ref.watch(authUidProvider).valueOrNull);
});
