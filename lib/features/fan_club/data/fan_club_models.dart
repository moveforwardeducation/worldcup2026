import 'package:flutter/foundation.dart';

@immutable
class TeamStanding {
  const TeamStanding({
    required this.teamId,
    required this.name,
    required this.flag,
    required this.confederation,
    required this.xp,
  });

  final String teamId;
  final String name;
  final String flag;
  final String confederation;
  final int xp;
}

@immutable
class MemberStanding {
  const MemberStanding({
    required this.name,
    required this.xp,
    required this.isYou,
  });

  final String name;
  final int xp;
  final bool isYou;
}

@immutable
class FanClubData {
  const FanClubData({
    required this.userTeamId,
    required this.userTeamName,
    required this.global,
    required this.country,
    required this.members,
    required this.backendLive,
  });

  final String userTeamId;
  final String userTeamName;
  final List<TeamStanding> global;
  final List<TeamStanding> country;
  final List<MemberStanding> members;
  final bool backendLive;

  int get userTeamRank {
    for (var i = 0; i < global.length; i++) {
      if (global[i].teamId == userTeamId) return i + 1;
    }
    return 0;
  }

  int get userTeamXp {
    for (final t in global) {
      if (t.teamId == userTeamId) return t.xp;
    }
    return 0;
  }
}
