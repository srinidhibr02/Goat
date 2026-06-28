import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/profile_providers.dart';

/// Notification preferences screen — persisted to SharedPreferences.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // ── Banner ──────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9933), Color(0xFFFFBB55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: Colors.white, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stay Updated',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get notified about festivals, events and your bookings.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Notification Types'),

          // ── Toggles ─────────────────────────────────────────────────────
          _NotifTile(
            icon: Icons.campaign_outlined,
            title: 'General Announcements',
            subtitle: 'Temple news and important updates',
            value: prefs[notifGeneralKey] ?? true,
            onChanged: (_) => notifier.toggle(notifGeneralKey),
          ),
          _NotifTile(
            icon: Icons.celebration_outlined,
            title: 'Festivals & Events',
            subtitle: 'Upcoming celebrations at your favourite temples',
            value: prefs[notifEventsKey] ?? true,
            onChanged: (_) => notifier.toggle(notifEventsKey),
          ),
          _NotifTile(
            icon: Icons.calendar_today_outlined,
            title: 'Booking Reminders',
            subtitle: 'Reminders 24 hrs before your darshan',
            value: prefs[notifBookingsKey] ?? true,
            onChanged: (_) => notifier.toggle(notifBookingsKey),
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Device Settings'),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.settings_outlined, size: 20, color: theme.colorScheme.onSurface),
            ),
            title: const Text('System Notification Settings'),
            subtitle: const Text('Manage permissions in device settings'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {
              // On a real device, open app notification settings via
              // app_settings package. For now show a snackbar.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Open Settings → Notifications → GOAT on your device.')),
              );
            },
          ),

          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Changes are saved automatically and take effect immediately.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ── Notification toggle tile ──────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: value
              ? AppColors.saffron.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20,
            color: value ? AppColors.saffron : theme.colorScheme.onSurfaceVariant),
      ),
      title: Text(title,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.saffron,
        onChanged: onChanged,
      ),
    );
  }
}
