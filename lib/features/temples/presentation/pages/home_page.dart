import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/domain/entities/feed_post.dart';
import '../../../feed/presentation/providers/feed_providers.dart';

/// Home screen — shows greeting header (with search + avatar icons) and
/// the Events & Updates feed only.
///
/// Tapping the search icon pushes [BrowseTemplesPage] (/browse).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final feedAsync = ref.watch(filteredFeedProvider);
    final hasFavs = ref.watch(hasFavouritesProvider);
    final selectedType = ref.watch(selectedFeedTypeProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(feedPostsProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(child: _Header(user: user)),

              // ── Events & Updates section title ───────────────────────────
              SliverToBoxAdapter(
                child: _FeedSectionHeader(
                  hasFavourites: hasFavs,
                  selected: selectedType,
                ),
              ),

              // ── Type filter chips ────────────────────────────────────────
              SliverToBoxAdapter(
                child: _FeedFilterBar(selected: selectedType),
              ),

              // ── Feed cards ───────────────────────────────────────────────
              feedAsync.when(
                data: (posts) => posts.isEmpty
                    ? SliverToBoxAdapter(
                        child: _FeedEmptyState(hasFavourites: hasFavs))
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        sliver: SliverList.separated(
                          itemCount: posts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _FeedCard(post: posts[i], currentUser: user),
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final AppUser? user;
  const _Header({this.user});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 🙏';
    if (h < 17) return 'Good afternoon 🙏';
    return 'Good evening 🙏';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final initial = (user?.displayName?.isNotEmpty == true
            ? user!.displayName![0]
            : 'D')
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
      child: Row(
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

          // Search icon → Browse Temples page
          Tooltip(
            message: 'Browse Temples',
            child: IconButton(
              onPressed: () => context.push('/browse'),
              icon: const Icon(Icons.search_rounded),
              iconSize: 26,
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Avatar → Profile
          Tooltip(
            message: 'Profile',
            child: GestureDetector(
              onTap: () => context.push('/profile'),
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
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Feed Section Header ───────────────────────────────────────────────────────

class _FeedSectionHeader extends StatelessWidget {
  final bool hasFavourites;
  final FeedPostType? selected;
  const _FeedSectionHeader(
      {required this.hasFavourites, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events & Updates',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  hasFavourites
                      ? 'From your favourite temples'
                      : 'From all temples',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasFavourites
                        ? AppColors.saffron
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: hasFavourites
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (hasFavourites)
            const Icon(Icons.favorite, size: 16, color: AppColors.saffron),
        ],
      ),
    );
  }
}

// ── Feed filter chips ─────────────────────────────────────────────────────────

class _FeedFilterBar extends ConsumerWidget {
  final FeedPostType? selected;
  const _FeedFilterBar({this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FeedChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () =>
                ref.read(selectedFeedTypeProvider.notifier).state = null,
          ),
          ...FeedPostType.values.map((t) => _FeedChip(
                label: '${t.emoji} ${t.displayName}',
                isSelected: selected == t,
                onTap: () =>
                    ref.read(selectedFeedTypeProvider.notifier).state = t,
              )),
        ],
      ),
    );
  }
}

class _FeedChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FeedChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.saffron.withValues(alpha: 0.15),
        checkmarkColor: AppColors.saffron,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.saffron
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      ),
    );
  }
}

// ── Feed Card with Like + Comment ─────────────────────────────────────────────

class _FeedCard extends ConsumerWidget {
  final FeedPost post;
  final AppUser? currentUser;
  const _FeedCard({required this.post, this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uid = currentUser?.uid ?? '';
    final isLiked = post.isLikedBy(uid);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          if (post.imageUrl != null)
            GestureDetector(
              onTap: () => context.push('/temple/${post.templeId}'),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  post.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge + temple name
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.push('/temple/${post.templeId}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.saffron.withValues(
                              alpha: isDark ? 0.2 : 0.12),
                        ),
                        child: Text(
                          '${post.type.emoji} ${post.type.displayName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.saffron,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            context.push('/temple/${post.templeId}'),
                        child: Text(
                          post.templeName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Title
                GestureDetector(
                  onTap: () => context.push('/temple/${post.templeId}'),
                  child: Text(
                    post.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 4),

                // Body
                Text(
                  post.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Timestamp + event date
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatRelative(post.publishedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (post.eventDate != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.event,
                          size: 12, color: AppColors.saffron),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM').format(post.eventDate!),
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.saffron,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 4),

                // Action row
                Row(
                  children: [
                    _ActionButton(
                      icon: isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: _compactCount(post.likeCount),
                      color: isLiked ? Colors.redAccent : null,
                      onTap: uid.isEmpty
                          ? null
                          : () => ref
                              .read(feedPostsProvider.notifier)
                              .toggleLike(post.id, uid),
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: _compactCount(post.commentCount),
                      onTap: () =>
                          _showComments(context, ref, post, currentUser),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _compactCount(int n) {
    if (n == 0) return '';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('d MMM').format(dt);
  }

  void _showComments(BuildContext context, WidgetRef ref, FeedPost post,
      AppUser? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(post: post, currentUser: user),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  const _ActionButton(
      {required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: iconColor, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Comments Sheet ────────────────────────────────────────────────────────────

class _CommentsSheet extends ConsumerStatefulWidget {
  final FeedPost post;
  final AppUser? currentUser;
  const _CommentsSheet({required this.post, this.currentUser});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _ctrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.currentUser == null) return;
    setState(() => _submitting = true);
    try {
      await ref.read(feedRepositoryProvider).addComment(
            postId: widget.post.id,
            uid: widget.currentUser!.uid,
            displayName: widget.currentUser!.displayName ?? 'Devotee',
            photoUrl: widget.currentUser!.photoUrl,
            text: text,
          );
      _ctrl.clear();
      ref.read(feedPostsProvider.notifier).onCommentAdded(widget.post.id);
      ref.invalidate(commentsProvider(widget.post.id));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text('Comments',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${widget.post.commentCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: commentsAsync.when(
                data: (comments) => comments.isEmpty
                    ? Center(
                        child: Text('Be the first to comment 🙏',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant)))
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _CommentTile(comment: comments[i]),
                      ),
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Failed to load comments')),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 8, 16,
                    MediaQuery.of(context).viewInsets.bottom + 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.saffron,
                      backgroundImage: widget.currentUser?.photoUrl != null
                          ? NetworkImage(widget.currentUser!.photoUrl!)
                          : null,
                      child: widget.currentUser?.photoUrl == null
                          ? Text(
                              (widget.currentUser?.displayName
                                          ?.isNotEmpty ==
                                      true
                                  ? widget.currentUser!.displayName![0]
                                  : 'D')
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700))
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add a comment…',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2))
                        : IconButton(
                            icon: const Icon(Icons.send_rounded,
                                color: AppColors.saffron),
                            onPressed: _submit,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Comment tile ──────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final FeedComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = comment.displayName.isNotEmpty
        ? comment.displayName[0].toUpperCase()
        : 'D';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.saffron,
          backgroundImage: comment.photoUrl != null
              ? NetworkImage(comment.photoUrl!)
              : null,
          child: comment.photoUrl == null
              ? Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(comment.displayName,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(
                    _fmt(comment.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(comment.text,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('d MMM').format(dt);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _FeedEmptyState extends StatelessWidget {
  final bool hasFavourites;
  const _FeedEmptyState({required this.hasFavourites});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.saffron.withValues(alpha: 0.08),
            ),
            child: const Icon(Icons.newspaper_outlined,
                size: 40, color: AppColors.saffron),
          ),
          const SizedBox(height: 16),
          Text(
            hasFavourites
                ? 'No posts from your favourites yet'
                : 'No events posted yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasFavourites
                ? 'Your favourite temples haven\'t posted anything yet.\nCheck back soon!'
                : 'Save temples as favourites to see\ntheir events and updates here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, height: 1.6),
          ),
          if (!hasFavourites) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.saffron,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/browse'),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Browse Temples',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}
