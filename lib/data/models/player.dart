import 'package:flutter/material.dart';

@immutable
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.teamId,
    required this.position,
    required this.overall,
    this.goals = 0,
    this.matches = 0,
    this.assists = 0,
    this.dob,
    this.worldCupApps = 0,
    this.bestFinish,
  });

  final String id;
  final String name;
  final String teamId;
  final String position;
  final int overall;
  final int goals;
  final int matches;
  final int assists;
  final String? dob;
  final int worldCupApps;
  final String? bestFinish;

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        teamId: json['teamId'] as String,
        position: json['position'] as String,
        overall: json['overall'] as int,
        goals: (json['goals'] as int?) ?? 0,
        matches: (json['matches'] as int?) ?? 0,
        assists: (json['assists'] as int?) ?? 0,
        dob: json['dob'] as String?,
        worldCupApps: (json['worldCupApps'] as int?) ?? 0,
        bestFinish: json['bestFinish'] as String?,
      );
}
