import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../data/providers.dart';
import '../../../data/remote/firebase_providers.dart';
import '../data/fan_club_models.dart';
import '../data/fan_club_repository.dart';

final fanClubRepositoryProvider = Provider<FanClubRepository>((ref) {
  final FirebaseFirestore? fs =
      firebaseReady ? ref.read(firestoreProvider) : null;
  return FanClubRepository(firestore: fs);
});

final fanClubProvider = FutureProvider<FanClubData>((ref) async {
  final teams = await ref.watch(teamsProvider.future);
  final profile = ref.watch(userProfileProvider);
  final xp = ref.watch(xpProvider);
  final uid = ref.watch(authUidProvider).valueOrNull;

  return ref.read(fanClubRepositoryProvider).load(
        teams: teams,
        userTeamId: profile?.favoriteTeamId ?? 'bra',
        username: profile?.username ?? 'You',
        userXp: xp.totalXp,
        uid: uid,
      );
});
