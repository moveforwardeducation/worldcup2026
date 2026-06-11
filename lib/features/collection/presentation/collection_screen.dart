import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../data/models/collectible_card.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import 'collection_providers.dart';
import 'widgets/card_fan_emblem.dart';
import 'widgets/card_tile.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  CardType? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(cardCatalogProvider);
    final unlocked = ref.watch(unlockedCardsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: catalogAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen)),
                error: (e, _) => Center(
                    child: Text('$e',
                        style: const TextStyle(color: AppColors.textSecondary))),
                data: (catalog) {
                  final filtered = _filter == null
                      ? catalog
                      : catalog.where((c) => c.type == _filter).toList();
                  final ownedCount =
                      catalog.where((c) => unlocked.contains(c.id)).length;

                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: BannerHeader(
                            title: 'Collection',
                            subtitle:
                                '$ownedCount of ${catalog.length} cards collected',
                            backdrop: const Confetti(),
                            emblem: const CardFanEmblem(size: 104),
                            action: HelpButton(topic: AppHelp.collection),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _FilterBar(
                          selected: _filter,
                          onSelect: (f) => setState(() => _filter = f),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final card = filtered[i];
                              return CardTile(
                                card: card,
                                unlocked: unlocked.contains(card.id),
                                onTap: () =>
                                    context.push('/collection/card', extra: card),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});
  final CardType? selected;
  final ValueChanged<CardType?> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(String, CardType?)>[
      ('All', null),
      ('Teams', CardType.team),
      ('Players', CardType.player),
      ('Stadiums', CardType.stadium),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final (label, type) = items[i];
          final active = selected == type;
          return GestureDetector(
            onTap: () => onSelect(type),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: active ? AppColors.greenCta : null,
                color: active ? null : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
