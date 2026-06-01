import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/feed_post.dart';
import '../providers/feed_providers.dart';

/// Devotee news feed — temple announcements, events and festivals.
class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(filteredFeedProvider);
    final selected = ref.watch(selectedFeedTypeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'Temple Feed',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                'News, events & announcements',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            // ── Filter chips ──────────────────────────────────────────────
            _FilterBar(selected: selected),

            // ── Posts list ────────────────────────────────────────────────
            Expanded(
              child: postsAsync.when(
                data: (posts) => posts.isEmpty
                    ? _EmptyState(selected: selected)
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.refresh(feedPostsProvider.future),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: posts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _FeedCard(post: posts[i]),
                        ),
                      ),
                loading: () => const _LoadingSkeleton(),
                error: (e, _) => _ErrorState(
                  onRetry: () => ref.invalidate(feedPostsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  final FeedPostType? selected;
  const _FilterBar({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'All',
            isSelected: selected == null,
            onTap: () =>
                ref.read(selectedFeedTypeProvider.notifier).state = null,
          ),
          ...FeedPostType.values.map((type) => _Chip(
                label: type.displayName,
                emoji: type.emoji,
                isSelected: selected == type,
                onTap: () =>
                    ref.read(selectedFeedTypeProvider.notifier).state = type,
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          label: Text(emoji != null ? '$emoji $label' : label),
          selected: isSelected,
          onSelected: (_) => onTap(),
          selectedColor: AppColors.saffron.withValues(alpha: 0.15),
          checkmarkColor: AppColors.saffron,
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.saffron
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.saffron
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          showCheckmark: false,
        ),
      ),
    );
  }
}

// ── Feed Card ─────────────────────────────────────────────────────────────────

class _FeedCard extends StatelessWidget {
  final FeedPost post;
  const _FeedCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional hero image
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(17)),
              child: Image.network(
                post.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _GradientHeader(type: post.type),
              ),
            )
          else
            _GradientHeader(type: post.type),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temple name
                Row(
                  children: [
                    if (post.templeImageUrl != null) ...[
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(post.templeImageUrl!),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        post.templeName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _TypeBadge(type: post.type),
                  ],
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  post.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Body
                Text(
                  post.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Footer: date + optional event date
                Row(
                  children: [
                    Icon(Icons.schedule_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatRelative(post.publishedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (post.eventDate != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.event_outlined,
                          size: 13, color: AppColors.saffron),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(post.eventDate!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.saffron,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }
}

// ── Gradient Header (shown when no image) ─────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final FeedPostType type;
  const _GradientHeader({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      child: Center(
        child: Text(
          type.emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  List<Color> get _gradientColors => switch (type) {
        FeedPostType.festival => [
            const Color(0xFFFF6B35),
            const Color(0xFFFFBB44),
          ],
        FeedPostType.event => [
            const Color(0xFF6C63FF),
            const Color(0xFFB8B2FF),
          ],
        FeedPostType.announcement => [
            const Color(0xFF00B4D8),
            const Color(0xFF90E0EF),
          ],
        FeedPostType.news => [
            const Color(0xFF2D9E6B),
            const Color(0xFF7ECBA1),
          ],
      };
}

// ── Type Badge ────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final FeedPostType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color get _color => switch (type) {
        FeedPostType.festival => const Color(0xFFFF6B35),
        FeedPostType.event => const Color(0xFF6C63FF),
        FeedPostType.announcement => const Color(0xFF00B4D8),
        FeedPostType.news => const Color(0xFF2D9E6B),
      };
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final FeedPostType? selected;
  const _EmptyState({this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected?.emoji ?? '📭',
                style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              selected != null
                  ? 'No ${selected!.displayName} posts yet'
                  : 'No posts yet',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for temple news and announcements.',
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

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: base,
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('Failed to load feed'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
