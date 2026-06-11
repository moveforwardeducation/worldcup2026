import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../data/models/team.dart';
import 'fan_club_models.dart';

/// Backs the Fan Club leaderboards. Team totals live in Firestore
/// (`teamLeaderboard`) and persist across sessions; the signed-in user
/// contributes their XP via their own member doc. Falls back to a fully
/// local computation when the backend isn't available.
class FanClubRepository {
  FanClubRepository({this.firestore});

  final FirebaseFirestore? firestore;

  int _baseXp(Team t) {
    final ranking = (t.fifaRanking ?? 30).clamp(1, 40);
    final base = 130000 - ranking * 1500;
    final variance = t.id.hashCode % 4000;
    return base + variance.abs();
  }

  /// Seeds the team leaderboard once, then reads standings, blending the
  /// user's XP into their favourite team.
  Future<FanClubData> load({
    required List<Team> teams,
    required String userTeamId,
    required String username,
    required int userXp,
    required String? uid,
  }) async {
    final fs = firestore;
    final base = {for (final t in teams) t.id: _baseXp(t)};
    final liveMembers = <MemberStanding>[];
    var backendLive = false;

    if (fs != null && uid != null) {
      try {
        await _ensureSeeded(fs, teams, base);
        // Persist the user's contribution to their club.
        await fs
            .collection('fanClubMembers')
            .doc(userTeamId)
            .collection('members')
            .doc(uid)
            .set({'name': username, 'xp': userXp});

        // Read team totals from Firestore.
        final snap = await fs.collection('teamLeaderboard').get();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (base.containsKey(doc.id)) {
            base[doc.id] = (data['baseXp'] as num?)?.toInt() ?? base[doc.id]!;
          }
        }

        // Read real club members (other signed-in fans).
        final memSnap = await fs
            .collection('fanClubMembers')
            .doc(userTeamId)
            .collection('members')
            .get();
        for (final d in memSnap.docs) {
          final data = d.data();
          liveMembers.add(MemberStanding(
            name: (data['name'] as String?) ?? 'Fan',
            xp: (data['xp'] as num?)?.toInt() ?? 0,
            isYou: d.id == uid,
          ));
        }
        backendLive = true;
      } catch (e) {
        if (kDebugMode) debugPrint('Fan club backend load failed: $e');
      }
    }

    // Blend the user's XP into their team for display + ranking.
    final standings = teams.map((t) {
      final xp = base[t.id]! + (t.id == userTeamId ? userXp : 0);
      return TeamStanding(
        teamId: t.id,
        name: t.name,
        flag: t.flagEmoji,
        confederation: t.confederation,
        xp: xp,
      );
    }).toList()
      ..sort((a, b) => b.xp.compareTo(a.xp));

    final userConf = teams
        .firstWhere((t) => t.id == userTeamId,
            orElse: () => teams.first)
        .confederation;
    final country = standings
        .where((s) => s.confederation == userConf)
        .toList();

    final userTeamName =
        teams.firstWhere((t) => t.id == userTeamId, orElse: () => teams.first).name;

    return FanClubData(
      userTeamId: userTeamId,
      userTeamName: userTeamName,
      global: standings,
      country: country,
      members: _members(username, userXp, liveMembers),
      backendLive: backendLive,
    );
  }

  Future<void> _ensureSeeded(
    FirebaseFirestore fs,
    List<Team> teams,
    Map<String, int> base,
  ) async {
    final marker = await fs.collection('teamLeaderboard').doc('_meta').get();
    if (marker.exists) return;
    final batch = fs.batch();
    for (final t in teams) {
      batch.set(fs.collection('teamLeaderboard').doc(t.id), {
        'name': t.name,
        'flag': t.flagEmoji,
        'baseXp': base[t.id],
      });
    }
    batch.set(fs.collection('teamLeaderboard').doc('_meta'),
        {'seeded': true, 'ts': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  /// Fan-club members: real Firestore members blended with locally generated
  /// club-mates so the board stays populated until there are enough users.
  List<MemberStanding> _members(
    String username,
    int userXp,
    List<MemberStanding> live,
  ) {
    final list = <MemberStanding>[];
    // Real members from Firestore (ensure the user is represented).
    final hasYou = live.any((m) => m.isYou);
    list.addAll(live);
    if (!hasYou) {
      list.add(MemberStanding(name: username, xp: userXp, isYou: true));
    }

    // Top up with filler so the board isn't sparse with few real users.
    const names = ['Lucas', 'Pedro', 'Mateo', 'Rafael', 'Gabriel', 'Bruno'];
    const factors = [1.7, 1.3, 0.85, 0.7, 0.55, 0.42];
    final existing = list.map((m) => m.name).toSet();
    for (var i = 0; i < names.length && list.length < 7; i++) {
      if (existing.contains(names[i])) continue;
      list.add(MemberStanding(
        name: names[i],
        xp: (userXp * factors[i]).round() + 500,
        isYou: false,
      ));
    }

    list.sort((a, b) => b.xp.compareTo(a.xp));
    return list;
  }
}
