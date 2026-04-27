import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/temple.dart';
import '../providers/search_provider.dart';
import '../widgets/temple_card.dart';

/// Search-focused temple browsing page with map/list toggle.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _mapController = MapController();
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider);
    final templesAsync = ref.watch(filteredTemplesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar: Search + Map/List toggle ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                      decoration: InputDecoration(
                        hintText: 'Search temples, cities, states…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .state = '';
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            theme.colorScheme.surfaceContainerHighest,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Map / List toggle button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _showMap
                          ? AppColors.saffron
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _showMap ? Icons.list : Icons.map_outlined,
                        color: _showMap
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                      tooltip: _showMap ? 'List View' : 'Map View',
                      onPressed: () => setState(() => _showMap = !_showMap),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content: Map or List ──────────────────────────────────
            Expanded(
              child: templesAsync.when(
                data: (temples) => _showMap
                    ? _TempleMapView(
                        temples: temples, mapController: _mapController)
                    : temples.isEmpty
                        ? _EmptySearch(query: query)
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: temples.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) =>
                                _TempleListTile(temple: temples[i]),
                          ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  onRetry: () =>
                      ref.refresh(filteredTemplesProvider.future),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map View ──────────────────────────────────────────────────────────────────

class _TempleMapView extends StatelessWidget {
  final List<Temple> temples;
  final MapController mapController;

  const _TempleMapView(
      {required this.temples, required this.mapController});

  @override
  Widget build(BuildContext context) {
    // Centre of India as default
    const indiaCenter = LatLng(20.5937, 78.9629);

    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: indiaCenter,
        initialZoom: 4.5,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        // OpenStreetMap tiles — no API key required
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.goat',
        ),
        // Temple markers
        MarkerLayer(
          markers: temples.map((temple) {
            return Marker(
              point: LatLng(temple.latitude, temple.longitude),
              width: 48,
              height: 48,
              child: GestureDetector(
                onTap: () => _showTempleSheet(context, temple),
                child: _TempleMarker(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showTempleSheet(BuildContext context, Temple temple) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TempleMapCard(temple: temple),
    );
  }
}

class _TempleMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.saffron,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.saffron.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.temple_hindu,
              color: Colors.white, size: 18),
        ),
        // Pin tail
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()..color = AppColors.saffron;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Temple map bottom-sheet card ──────────────────────────────────────────────

class _TempleMapCard extends StatelessWidget {
  final Temple temple;
  const _TempleMapCard({required this.temple});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    temple.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.temple_hindu,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temple.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${temple.city}, ${temple.state}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFD700), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            temple.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  TempleCard.navigateToDetail(context, temple);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('View Details'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────────

class _TempleListTile extends StatelessWidget {
  final Temple temple;
  const _TempleListTile({required this.temple});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => TempleCard.navigateToDetail(context, temple),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Image.network(
                temple.imageUrl,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 90,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.temple_hindu,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${temple.city}, ${temple.state}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          temple.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        if (temple.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.saffron,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '✓ Verified',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty search ──────────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'Search for temples'
                  : 'No results for "$query"',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Try searching by temple name, city, or state'
                  : 'Try a different search term or category',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('Failed to load temples',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.saffron),
            ),
          ],
        ),
      ),
    );
  }
}
