import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/temple_category.dart';
import '../providers/temples_providers.dart';
import '../widgets/temple_card.dart';

/// Main home screen — greeting, search bar, category filter, temple grid.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final templesAsync = ref.watch(templesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(templesProvider.future),
          child: CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────────────
              SliverToBoxAdapter(child: _Header(user: user, ref: ref)),

              // ── Category Chips ────────────────────────────────────────
              SliverToBoxAdapter(
                child: _CategoryFilter(selected: selectedCategory),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Temple Grid ───────────────────────────────────────────
              templesAsync.when(
                data: (temples) => temples.isEmpty
                    ? SliverFillRemaining(
                        child: _EmptyState(),
                      )
                    : SliverPadding(
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
                          itemBuilder: (_, i) =>
                              TempleCard(temple: temples[i]),
                        ),
                      ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        Text('Failed to load temples',
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.refresh(templesProvider.future),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppUser? user;
  final WidgetRef ref;

  const _Header({this.user, required this.ref});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 🙏';
    if (h < 17) return 'Good afternoon 🙏';
    return 'Good evening 🙏';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = (user?.displayName?.isNotEmpty == true
            ? user!.displayName![0]
            : 'D')
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Greeting + name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.displayName ?? 'Devotee',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // Avatar with sign-out menu
              PopupMenuButton<String>(
                offset: const Offset(0, 52),
                tooltip: 'Account',
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.saffron,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700))
                      : null,
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'signout',
                    onTap: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    child: const Row(children: [
                      Icon(Icons.logout),
                      SizedBox(width: 12),
                      Text('Sign Out'),
                    ]),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search bar (UI only — search logic in a future step)
          TextField(
            decoration: InputDecoration(
              hintText: 'Search temples, cities…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category filter ───────────────────────────────────────────────────────────

class _CategoryFilter extends ConsumerWidget {
  final TempleCategory selected;

  const _CategoryFilter({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TempleCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = TempleCategory.values[i];
          final isSelected = cat == selected;
          return FilterChip(
            label: Text(cat.displayName),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(selectedCategoryProvider.notifier).state = cat,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            selectedColor: AppColors.saffron.withValues(alpha: 0.15),
            checkmarkColor: AppColors.saffron,
            side: BorderSide(
              color: isSelected
                  ? AppColors.saffron
                  : theme.colorScheme.outlineVariant,
            ),
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? AppColors.saffron
                  : theme.colorScheme.onSurface,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.temple_hindu,
              size: 72, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No temples in this category',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Try selecting a different filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
