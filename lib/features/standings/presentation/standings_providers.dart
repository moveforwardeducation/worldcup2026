import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/fixture.dart';
import '../../predictions/presentation/predictions_providers.dart';
import '../domain/standings_builder.dart';

/// Group standings derived from the (synced) fixtures. Empty until group-stage
/// fixtures with group info are available.
final standingsProvider = Provider<List<GroupStanding>>((ref) {
  final fixtures = ref.watch(fixturesProvider).valueOrNull ?? const <Fixture>[];
  return buildStandings(fixtures);
});
