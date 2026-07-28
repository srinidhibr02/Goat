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
import '../../domain/entities/temple_category.dart';
import '../providers/search_provider.dart';
import '../providers/temples_providers.dart';
import '../widgets/temple_card.dart';

/// Unified home screen — Events & Updates feed at top, temple browse below.
/// Profile is accessed by tapping the avatar on the top-right.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final templesAsync = ref.watch(filteredTemplesProvider);
    final feedAsync = ref.watch(filteredFeedProvider);
    final hasFavs = ref.watch(hasFavouritesProvider);
    final selectedType = ref.watch(selectedFeedTypeProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(filteredTemplesProvider);
            await ref.read(feedPostsProvider.notifier).refresh();
          },
          child: CustomScrollView(
            slivers: [
              // ── Greeting header ──────────────────────────────────────────
              SliverToBoxAdapter(child: _Header(user: user)),

              // ── Events & Updates ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: _FeedSectionHeader(
                  hasFavourites: hasFavs,
                  selected: selectedType,
                ),
              ),

              // Feed type filter chips
              SliverToBoxAdapter(
                child: _FeedFilterBar(selected: selectedType),
              ),

              // Feed cards
              feedAsync.when(
                data: (posts) => posts.isEmpty
                    ? SliverToBoxAdapter(
                        child: _FeedEmptyState(hasFavourites: hasFavs))
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                    child: SizedBox.shrink()),
              ),

              // ── Divider before temple browse ─────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Divider(),
                ),
              ),

              // ── Browse Temples header ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Browse Temples',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              // Temple search bar
              SliverToBoxAdapter(child: _SearchBar()),

              // Category chips
              SliverToBoxAdapter(
                child: _CategoryFilter(selected: selectedCategory),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Temple grid
              templesAsync.when(
                data: (temples) => temples.isEmpty
                    ? const SliverToBoxAdapter(child: _TempleEmptyState())
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
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
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 40),
                        const SizedBox(height: 8),
                        Text('Failed to load temples',
                            style: Theme.of(context).textTheme.bodyMedium),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting Header ───────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
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
                            color: Colors.white, fontWeight: FontWeight.w700))
                    : null,
              ),
            ),
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
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
                    fontWeight:
                        hasFavourites ? FontWeight.w600 : FontWeight.normal,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                // Type badge + temple name row
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

                // Body preview
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

                // ── Action row: Like + Comment ───────────────────────────
                Row(
                  children: [
                    // Like button
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

                    // Comment button
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

// ── Action button (Like / Comment) ────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        color ?? theme.colorScheme.onSurfaceVariant;
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
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: iconColor, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Comments Bottom Sheet ─────────────────────────────────────────────────────

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
      // Patch comment count in the feed list
      ref.read(feedPostsProvider.notifier).onCommentAdded(widget.post.id);
      // Refresh the comments for this post
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
            // Handle
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

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.post.commentCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Comments list
            Expanded(
              child: commentsAsync.when(
                data: (comments) => comments.isEmpty
                    ? Center(
                        child: Text('Be the first to comment 🙏',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant)),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _CommentTile(comment: comments[i]),
                      ),
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                    child: Text('Failed to load comments')),
              ),
            ),

            // Input bar
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).viewInsets.bottom + 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.saffron,
                      backgroundImage:
                          widget.currentUser?.photoUrl != null
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
                                  fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textCapitalization:
                            TextCapitalization.sentences,
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
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
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
                    _formatRelative(comment.createdAt),
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

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('d MMM').format(dt);
  }
}

// ── Temple Browse widgets ─────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _ctrl,
        onChanged: (v) => updateSearchQuery(ref, v),
        decoration: InputDecoration(
          hintText: 'Search temples, cities…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _ctrl.clear();
                    updateSearchQuery(ref, '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _TempleEmptyState extends StatelessWidget {
  const _TempleEmptyState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(children: [
        Icon(Icons.temple_hindu,
            size: 56, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 12),
        Text('No temples found', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Try a different search or category',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  final bool hasFavourites;
  const _FeedEmptyState({required this.hasFavourites});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(children: [
        Text(
          hasFavourites
              ? 'No posts from your favourites yet 📭'
              : 'No events posted yet 📭',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (!hasFavourites) ...[
          const SizedBox(height: 6),
          Text(
            'Save temples as favourites to see their events here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ]),
    );
  }
}
