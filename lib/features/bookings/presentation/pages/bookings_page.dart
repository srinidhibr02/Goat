import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../providers/bookings_provider.dart';

/// Bookings tab — shows upcoming and past bookings.
class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingBookingsProvider);
    final past = ref.watch(pastBookingsProvider);
    final hasBookings = upcoming.isNotEmpty || past.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: hasBookings
            ? _BookingsList(upcoming: upcoming, past: past)
            : const _EmptyBookings(),
      ),
    );
  }
}

// ── Bookings List ─────────────────────────────────────────────────────────────

class _BookingsList extends StatelessWidget {
  final List<Booking> upcoming;
  final List<Booking> past;

  const _BookingsList({required this.upcoming, required this.past});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Bookings',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          if (upcoming.isNotEmpty) ...[
            Text('Upcoming',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            ...upcoming.map((b) => _BookingCard(booking: b)),
          ],

          if (past.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Past & Cancelled',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            ...past.map((b) => _BookingCard(booking: b)),
          ],
        ],
      ),
    );
  }
}

// ── Booking Card ──────────────────────────────────────────────────────────────

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCancelled = booking.status == BookingStatus.cancelled;
    final dateStr = DateFormat('d MMM yyyy').format(booking.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: isCancelled
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              booking.templeImageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.temple_hindu, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.templeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(booking.timeSlot.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 6),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isCancelled
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    booking.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCancelled
                          ? theme.colorScheme.error
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cancel button
          if (!isCancelled)
            IconButton(
              icon: Icon(Icons.cancel_outlined,
                  color: theme.colorScheme.error.withValues(alpha: 0.7)),
              tooltip: 'Cancel booking',
              onPressed: () => _confirmCancel(context, ref),
            ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
            'Are you sure you want to cancel your booking at ${booking.templeName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookingsProvider.notifier).cancelBooking(booking.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(
                  content: Text('Booking cancelled'),
                  duration: Duration(seconds: 2),
                ));
            },
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

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
                    AppColors.saffron
                        .withValues(alpha: isDark ? 0.25 : 0.12),
                    AppColors.turmeric
                        .withValues(alpha: isDark ? 0.25 : 0.12),
                  ],
                ),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 56,
                color: AppColors.saffron.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Bookings Yet',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Visit a temple and tap "Book a Visit" to schedule your darshan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => GoRouter.of(context).go('/home'),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore Temples'),
            ),
          ],
        ),
      ),
    );
  }
}
