import 'package:flutter_test/flutter_test.dart';

import 'package:road_to_wc2026/data/models/fixture.dart';
import 'package:road_to_wc2026/features/predictions/domain/group_builder.dart';
import 'package:road_to_wc2026/features/predictions/presentation/predictions_providers.dart';

Fixture _fx({
  required String id,
  required String a,
  required String b,
  int sa = 0,
  int sb = 0,
  String? status,
  String? group,
  String dateLabel = '',
}) =>
    Fixture(
      id: id,
      teamA: a,
      teamB: b,
      dateLabel: dateLabel,
      scoreA: sa,
      scoreB: sb,
      kickoffInMinutes: 0,
      kickoffMs: 0,
      status: status,
      group: group,
    );

void main() {
  group('Fixture.groupLetter', () {
    test('reads explicit group field (GROUP_A)', () {
      expect(_fx(id: '1', a: 'usa', b: 'mex', group: 'GROUP_C').groupLetter,
          'C');
    });

    test('parses from dateLabel when group field absent', () {
      expect(
          _fx(id: '1', a: 'usa', b: 'mex', dateLabel: 'Group F · MD1')
              .groupLetter,
          'F');
    });

    test('is null for knockout matches', () {
      expect(
          _fx(id: '1', a: 'usa', b: 'mex', dateLabel: 'Round of 16')
              .groupLetter,
          isNull);
      expect(_fx(id: '1', a: 'usa', b: 'mex', group: '').groupLetter, isNull);
    });
  });

  group('buildGroupsFromFixtures', () {
    test('returns empty when no fixtures carry group info', () {
      final groups = buildGroupsFromFixtures([
        _fx(id: '1', a: 'arg', b: 'bra', dateLabel: 'Round of 16'),
      ]);
      expect(groups, isEmpty);
    });

    test('buckets teams into the right groups', () {
      final groups = buildGroupsFromFixtures([
        _fx(id: '1', a: 'usa', b: 'mex', group: 'GROUP_A'),
        _fx(id: '2', a: 'can', b: 'par', group: 'GROUP_A'),
        _fx(id: '3', a: 'bra', b: 'esp', group: 'GROUP_B'),
      ]);
      expect(groups.length, 2);
      expect(groups[0].name, 'Group A');
      expect(groups[0].teamIds.toSet(), {'usa', 'mex', 'can', 'par'});
      expect(groups[1].name, 'Group B');
      expect(groups[1].teamIds.toSet(), {'bra', 'esp'});
    });

    test('open until all group matches finished', () {
      final anchor = DateTime.now().millisecondsSinceEpoch;
      final now = anchor;
      // One finished, one still scheduled -> group is open.
      final groups = buildGroupsFromFixtures([
        _fx(id: '1', a: 'usa', b: 'mex', sa: 2, sb: 0, status: 'finished', group: 'GROUP_A'),
        _fx(id: '2', a: 'usa', b: 'can', status: 'scheduled', group: 'GROUP_A'),
      ]);
      expect(groups.length, 1);
      expect(groupStatus(groups.first, anchor, now), PredStatus.open);
    });

    test('resolves with correct winner by points when all finished', () {
      final anchor = DateTime.now().millisecondsSinceEpoch;
      final now = anchor;
      // Group of 3 mini-table: usa beats mex and can; can beats mex.
      final groups = buildGroupsFromFixtures([
        _fx(id: '1', a: 'usa', b: 'mex', sa: 2, sb: 0, status: 'finished', group: 'GROUP_A'),
        _fx(id: '2', a: 'usa', b: 'can', sa: 1, sb: 0, status: 'finished', group: 'GROUP_A'),
        _fx(id: '3', a: 'can', b: 'mex', sa: 3, sb: 1, status: 'finished', group: 'GROUP_A'),
      ]);
      final g = groups.single;
      expect(groupStatus(g, anchor, now), PredStatus.resolved);
      // usa: 6 pts (top), can: 3, mex: 0.
      expect(g.teamIds.first, 'usa');
      expect(g.winnerId, 'usa');
      expect(g.winnerIndex, 0);
    });

    test('goal difference breaks a points tie', () {
      // Two teams both win once; bra wins by more goals -> ranked first.
      final groups = buildGroupsFromFixtures([
        _fx(id: '1', a: 'bra', b: 'srb', sa: 4, sb: 0, status: 'finished', group: 'GROUP_B'),
        _fx(id: '2', a: 'sui', b: 'cmr', sa: 1, sb: 0, status: 'finished', group: 'GROUP_B'),
        _fx(id: '3', a: 'bra', b: 'sui', sa: 0, sb: 1, status: 'finished', group: 'GROUP_B'),
        _fx(id: '4', a: 'srb', b: 'cmr', sa: 3, sb: 3, status: 'finished', group: 'GROUP_B'),
      ]);
      final g = groups.single;
      // sui: 6 pts tops. srb & cmr both 1 pt -> cmr (gd -1) above srb (gd -4).
      expect(g.teamIds.first, 'sui');
      expect(g.teamIds.indexOf('cmr'), lessThan(g.teamIds.indexOf('srb')));
    });
  });
}
