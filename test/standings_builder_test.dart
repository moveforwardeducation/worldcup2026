import 'package:flutter_test/flutter_test.dart';

import 'package:road_to_wc2026/data/models/fixture.dart';
import 'package:road_to_wc2026/features/standings/domain/standings_builder.dart';

Fixture _fx({
  required String a,
  required String b,
  int sa = 0,
  int sb = 0,
  String? status,
  String? group,
}) =>
    Fixture(
      id: '$a$b',
      teamA: a,
      teamB: b,
      dateLabel: '',
      scoreA: sa,
      scoreB: sb,
      kickoffInMinutes: 0,
      kickoffMs: 0,
      status: status,
      group: group,
    );

void main() {
  test('empty when no group fixtures', () {
    expect(buildStandings([_fx(a: 'arg', b: 'bra')]), isEmpty);
  });

  test('computes P/W/D/L/GF/GA/GD/Pts and orders correctly', () {
    final standings = buildStandings([
      _fx(a: 'usa', b: 'mex', sa: 2, sb: 0, status: 'finished', group: 'GROUP_A'),
      _fx(a: 'can', b: 'par', sa: 1, sb: 1, status: 'finished', group: 'GROUP_A'),
      _fx(a: 'usa', b: 'can', sa: 3, sb: 1, status: 'finished', group: 'GROUP_A'),
    ]);
    expect(standings.length, 1);
    final g = standings.single;
    expect(g.name, 'Group A');
    // usa: 2 wins -> 6 pts, GF 5 GA 1 GD +4, leads.
    final usa = g.rows.first;
    expect(usa.teamId, 'usa');
    expect(usa.played, 2);
    expect(usa.won, 2);
    expect(usa.points, 6);
    expect(usa.goalsFor, 5);
    expect(usa.goalsAgainst, 1);
    expect(usa.goalDiff, 4);
    // mex: 1 played, lost -> 0 pts, bottom-ish.
    final mex = g.rows.firstWhere((r) => r.teamId == 'mex');
    expect(mex.played, 1);
    expect(mex.lost, 1);
    expect(mex.points, 0);
  });

  test('unplayed teams still appear with zeros', () {
    final standings = buildStandings([
      _fx(a: 'bra', b: 'srb', status: 'scheduled', group: 'GROUP_B'),
    ]);
    final g = standings.single;
    expect(g.rows.length, 2);
    expect(g.rows.every((r) => r.played == 0 && r.points == 0), isTrue);
  });

  test('goal difference breaks points tie', () {
    final standings = buildStandings([
      _fx(a: 'bra', b: 'srb', sa: 4, sb: 0, status: 'finished', group: 'GROUP_B'),
      _fx(a: 'sui', b: 'cmr', sa: 1, sb: 0, status: 'finished', group: 'GROUP_B'),
    ]);
    final g = standings.single;
    // bra & sui both 3 pts; bra GD +4 > sui GD +1 -> bra first.
    expect(g.rows.first.teamId, 'bra');
  });
}
