import 'package:flutter/material.dart';

/// A national football team.
@immutable
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.code,
    required this.flagEmoji,
    required this.confederation,
    required this.primaryColor,
    required this.secondaryColor,
    this.fifaRanking,
    this.worldCupWins = 0,
    this.bestFinish,
    this.headCoach,
    this.captain,
    this.firstWorldCup,
    this.topScorerName,
    this.topScorerGoals,
    this.fanFact,
  });

  final String id;
  final String name;
  final String code;
  final String flagEmoji;
  final String confederation;
  final int primaryColor;
  final int secondaryColor;
  final int? fifaRanking;
  final int worldCupWins;
  final String? bestFinish;
  final String? headCoach;
  final String? captain;
  final int? firstWorldCup;
  final String? topScorerName;
  final int? topScorerGoals;
  final String? fanFact;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        flagEmoji: json['flagEmoji'] as String,
        confederation: json['confederation'] as String,
        primaryColor: json['primaryColor'] as int,
        secondaryColor: json['secondaryColor'] as int,
        fifaRanking: json['fifaRanking'] as int?,
        worldCupWins: (json['worldCupWins'] as int?) ?? 0,
        bestFinish: json['bestFinish'] as String?,
        headCoach: json['headCoach'] as String?,
        captain: json['captain'] as String?,
        firstWorldCup: json['firstWorldCup'] as int?,
        topScorerName: json['topScorerName'] as String?,
        topScorerGoals: json['topScorerGoals'] as int?,
        fanFact: json['fanFact'] as String?,
      );
}
