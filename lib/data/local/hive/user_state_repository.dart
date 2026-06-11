import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../models/streak.dart';
import '../../models/user_profile.dart';
import '../../models/xp_state.dart';
import 'hive_boxes.dart';

/// Reads/writes all mutable user state stored in Hive.
/// Stored as plain Maps for forward-compat — no custom adapters needed.
class UserStateRepository {
  Box get _profile => Hive.box(HiveBoxes.userProfile);
  Box get _xp => Hive.box(HiveBoxes.xpState);
  Box get _streak => Hive.box(HiveBoxes.streak);

  // --- Profile ---
  UserProfile? readProfile() {
    final map = _profile.get('me');
    if (map == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(map as Map));
  }

  Future<void> writeProfile(UserProfile profile) =>
      _profile.put('me', profile.toMap());

  // --- XP ---
  XpState readXp() {
    final map = _xp.get('state');
    if (map == null) return XpState.initial;
    return XpState.fromMap(Map<String, dynamic>.from(map as Map));
  }

  Future<void> writeXp(XpState state) => _xp.put('state', state.toMap());

  // --- Streak ---
  StreakState readStreak() {
    final map = _streak.get('state');
    if (map == null) return StreakState.initial;
    return StreakState.fromMap(Map<String, dynamic>.from(map as Map));
  }

  Future<void> writeStreak(StreakState state) =>
      _streak.put('state', state.toMap());
}
