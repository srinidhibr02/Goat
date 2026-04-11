import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/temple.dart';

/// Premium card used in the temple grid on the home screen.
class TempleCard extends StatelessWidget {
  final Temple temple;

  const TempleCard({super.key, required this.temple});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/temple/${temple.id}', extra: temple),
      child: Hero(
        tag: 'temple-${temple.id}',
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background image ──────────────────────────────────
                Image.network(
                  temple.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
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
    );
  }
}
