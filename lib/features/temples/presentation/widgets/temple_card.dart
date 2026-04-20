import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/temple.dart';
import '../providers/favorites_provider.dart';

/// Premium card used in the temple grid on the home screen.
class TempleCard extends ConsumerStatefulWidget {
  final Temple temple;

  const TempleCard({super.key, required this.temple});

  /// Shared navigation helper so both TempleCard and explore list tiles
  /// use the same route.
  static void navigateToDetail(BuildContext context, Temple temple) {
    context.push('/temple/${temple.id}', extra: temple);
  }

  @override
  ConsumerState<TempleCard> createState() => _TempleCardState();
}

class _TempleCardState extends ConsumerState<TempleCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temple = widget.temple;
    final isFav = ref.watch(isFavoriteProvider(temple.id));

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        TempleCard.navigateToDetail(context, temple);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Hero(
          tag: 'temple-${temple.id}',
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Background image with loading placeholder ─────────
                  Image.network(
                    temple.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : _ImagePlaceholder(theme: theme),
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.temple_hindu,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  // ── Gradient overlay ──────────────────────────────────
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.35, 1.0],
                      ),
                    ),
                  ),

                  // ── Favorite button (top-right) ─────────────────────
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(favoritesProvider.notifier)
                            .toggle(temple.id);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 17,
                          color: isFav ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // ── Info overlay ──────────────────────────────────────
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (temple.isVerified)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9933),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '✓ Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        Text(
                          temple.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 11),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                temple.city,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.star,
                                color: Color(0xFFFFD700), size: 11),
                            const SizedBox(width: 2),
                            Text(
                              temple.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Image loading placeholder ─────────────────────────────────────────────────

class _ImagePlaceholder extends StatefulWidget {
  final ThemeData theme;
  const _ImagePlaceholder({required this.theme});

  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        final value = _shimmerController.value;
        final baseColor = widget.theme.colorScheme.surfaceContainerHighest;
        final highlightColor = widget.theme.colorScheme.surface;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(value * 2 - 1, 0),
              end: Alignment(value * 2, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.temple_hindu,
              size: 32,
              color: widget.theme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}
