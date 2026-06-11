import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/temple.dart';
import '../providers/favorites_provider.dart';
import '../providers/temples_providers.dart';
import '../widgets/temple_card.dart';

// ── Derived provider: list of full Temple objects for favorited IDs ────────────

/// Resolves favorited temple IDs → full [Temple] objects by cross-referencing
/// the full temple list. Falls back gracefully if a temple can't be found.
final favoriteTemplesProvider = FutureProvider<List<Temple>>((ref) async {
  final favIds = ref.watch(favoritesProvider);
  if (favIds.isEmpty) return [];

  // Re-use the already-fetched full list (no extra network call).
  final allAsync = ref.watch(templesProvider);
  final all = allAsync.valueOrNull ?? [];

  // Maintain insertion order of favorites.
  final byId = {for (final t in all) t.id: t};
  return favIds.map((id) => byId[id]).whereType<Temple>().toList();
});

/// The Favorites tab — grid of temples the user has hearted.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favoriteTemplesProvider);

    return Scaffold(
      body: SafeArea(
        child: favsAsync.when(
          data: (temples) => temples.isEmpty
              ? const _EmptyFavorites()
              : RefreshIndicator(
                  onRefresh: () => ref.refresh(favoriteTemplesProvider.future),
                  child: CustomScrollView(
                    slivers: [
                      // ── Header ─────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Favourites',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${temples.length} saved ${temples.length == 1 ? 'temple' : 'temples'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Grid ───────────────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: temples.length,
                          itemBuilder: (_, i) => TempleCard(temple: temples[i]),
                        ),
                      ),
                    ],
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load favourites',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.refresh(favoriteTemplesProvider.future),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.redAccent.withValues(alpha: isDark ? 0.25 : 0.12),
                    AppColors.saffron.withValues(alpha: isDark ? 0.25 : 0.12),
                  ],
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: Colors.redAccent.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Favourites Yet',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the ♡ on any temple card to save it here for quick access.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
