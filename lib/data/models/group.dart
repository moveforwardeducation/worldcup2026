import 'package:flutter/foundation.dart';

/// A World Cup group. Users predict the group winner; resolved when the group
/// "concludes" (demo timing; production uses real standings).
@immutable
class GroupInfo {
  const GroupInfo({
    required this.id,
    required this.name,
    required this.teamIds,
    required this.winnerId,
    required this.concludeInMinutes,
  });

  final String id;
  final String name;
  final List<String> teamIds;
  final String winnerId;
  final int concludeInMinutes;

  int get winnerIndex => teamIds.indexOf(winnerId);

  factory GroupInfo.fromJson(Map<String, dynamic> json) => GroupInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        teamIds: (json['teamIds'] as List).cast<String>(),
        winnerId: json['winnerId'] as String,
        concludeInMinutes: (json['concludeInMinutes'] as int?) ?? 60,
      );
}
