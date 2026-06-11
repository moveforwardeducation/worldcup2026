import 'package:flutter/foundation.dart';

/// A live in-match challenge "moment" (YES/NO). Several moments can belong to
/// the same match (grouped by [matchId]).
///
/// Whether a match is *live* is determined by a time window. In the demo this
/// comes from [startsInMinutes]/[durationMinutes] (relative to app open); in
/// production the backend marks fixtures `in_play` and the app shows only those.
@immutable
class LiveChallenge {
  const LiveChallenge({
    required this.id,
    required this.matchId,
    required this.matchLabel,
    required this.minute,
    required this.teamId,
    required this.question,
    required this.answerYes,
    required this.xp,
    required this.startsInMinutes,
    required this.durationMinutes,
  });

  final String id;
  final String matchId;
  final String matchLabel;
  final String minute;
  final String teamId;
  final String question;

  /// The correct answer (true = YES).
  final bool answerYes;
  final int xp;

  /// Kickoff offset from "now" in minutes (negative = already started).
  final int startsInMinutes;
  final int durationMinutes;

  /// The match is live if "now" falls within [kickoff, kickoff + duration].
  bool get isLive =>
      startsInMinutes <= 0 && (startsInMinutes + durationMinutes) > 0;

  factory LiveChallenge.fromJson(Map<String, dynamic> json) => LiveChallenge(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        matchLabel: json['matchLabel'] as String,
        minute: json['minute'] as String,
        teamId: json['teamId'] as String,
        question: json['question'] as String,
        answerYes: json['answerYes'] as bool,
        xp: (json['xp'] as int?) ?? 20,
        startsInMinutes: (json['startsInMinutes'] as int?) ?? 0,
        durationMinutes: (json['durationMinutes'] as int?) ?? 95,
      );
}
