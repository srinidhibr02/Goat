import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/temple_category.dart';
import '../providers/search_provider.dart';
import '../providers/temples_providers.dart';
import '../widgets/temple_card.dart';

/// Full-screen temple browse page: search bar + category filter + temple grid.
/// Pushed from the home-screen search icon via GoRouter (/browse).
class BrowseTemplesPage extends ConsumerStatefulWidget {
  const BrowseTemplesPage({super.key});

  @override
  ConsumerState<BrowseTemplesPage> createState() => _BrowseTemplesPageState();
}

class _BrowseTemplesPageState extends ConsumerState<BrowseTemplesPage> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pre-fill with any existing query
    _searchCtrl.text = ref.read(searchQueryProvider);
    // Auto-focus the search field when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final templesAsync = ref.watch(filteredTemplesProvider);

    return Scaffold(
      // ── App bar with embedded search field ──────────────────────────────
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => updateSearchQuery(ref, v),
          decoration: InputDecoration(
            hintText: 'Search temples, cities, deities…',
            border: InputBorder.none,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Clear',
              onPressed: () {
                _searchCtrl.clear();
                updateSearchQuery(ref, '');
              },
            ),
          const SizedBox(width: 4),
        ],
        elevation: 0,
        scrolledUnderElevation: 2,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category filter chips ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: TempleCategory.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = TempleCategory.values[i];
                  final isSelected = cat == selectedCategory;
                  return FilterChip(
                    label: Text(cat.displayName),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = cat,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    selectedColor:
                        AppColors.saffron.withValues(alpha: 0.15),
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Result count ───────────────────────────────────────────────
          templesAsync.whenData((temples) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Text(
                query.isNotEmpty
                    ? '${temples.length} result${temples.length == 1 ? '' : 's'} for "$query"'
                    : '${temples.length} temple${temples.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            );
          }).valueOrNull ?? const SizedBox.shrink(),

          // ── Temple grid ────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(filteredTemplesProvider),
              child: templesAsync.when(
                data: (temples) => temples.isEmpty
                    ? _EmptyState(query: query)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load temples',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(filteredTemplesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(Icons.temple_hindu_outlined,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              query.isNotEmpty
                  ? 'No temples found for\n"$query"'
                  : 'No temples found',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or category.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
