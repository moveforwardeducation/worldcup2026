import 'package:flutter/foundation.dart';

/// Renderable jersey patterns (normalized from the spec).
enum JerseyPattern { solid, stripes, halves, sash, checker, hoops }

JerseyPattern _parsePattern(String? s) {
  switch (s) {
    case 'stripes':
      return JerseyPattern.stripes;
    case 'halves':
      return JerseyPattern.halves;
    case 'sash':
      return JerseyPattern.sash;
    case 'checker':
      return JerseyPattern.checker;
    case 'hoops':
      return JerseyPattern.hoops;
    default:
      return JerseyPattern.solid;
  }
}

int _hex(String h) => int.parse('FF${h.replaceAll('#', '')}', radix: 16);

/// A data-driven jersey spec. Most fields default sensibly so the JSON can be
/// compact (body + collar + pattern is usually enough).
@immutable
class TeamJersey {
  const TeamJersey({
    required this.team,
    required this.fifaCode,
    required this.body,
    required this.collar,
    required this.sleeveTrim,
    required this.shoulderPanels,
    required this.numberArea,
    required this.patternColor,
    required this.pattern,
  });

  final String team;
  final String fifaCode;
  final int body;
  final int collar;
  final int sleeveTrim;
  final int shoulderPanels;
  final int numberArea;
  final int patternColor;
  final JerseyPattern pattern;

  factory TeamJersey.fromJson(Map<String, dynamic> j) {
    final body = _hex(j['body'] as String);
    final collar = _hex(j['collar'] as String);
    int? opt(String k) => j[k] != null ? _hex(j[k] as String) : null;
    return TeamJersey(
      team: j['team'] as String? ?? '',
      fifaCode: (j['fifaCode'] as String? ?? '').toUpperCase(),
      body: body,
      collar: collar,
      sleeveTrim: opt('sleeveTrim') ?? collar,
      shoulderPanels: opt('shoulderPanels') ?? body,
      numberArea: opt('numberArea') ?? collar,
      patternColor: opt('patternColor') ?? collar,
      pattern: _parsePattern(j['pattern'] as String?),
    );
  }

  /// Fallback when no spec exists — derive a solid kit from two colours.
  factory TeamJersey.fromColors({
    required String name,
    required int body,
    required int accent,
  }) =>
      TeamJersey(
        team: name,
        fifaCode: '',
        body: body,
        collar: accent,
        sleeveTrim: accent,
        shoulderPanels: body,
        numberArea: accent,
        patternColor: accent,
        pattern: JerseyPattern.solid,
      );
}
