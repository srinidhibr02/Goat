import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

/// User profile page — avatar, settings, sign out.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final themeMode = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    final initial = (user?.displayName?.isNotEmpty == true
            ? user!.displayName![0]
            : 'D')
        .toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ── Avatar + User Info ──────────────────────────────────────
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.saffron,
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Devotee',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit profile coming soon 🙏'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
              ),

              const SizedBox(height: 32),

              // ── Settings Section ────────────────────────────────────────
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: themeMode == ThemeMode.dark ||
                      (themeMode == ThemeMode.system && isDark),
                  activeTrackColor: AppColors.saffron,
                  onChanged: (on) {
                    ref.read(themeProvider.notifier).toggle(on);
                  },
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'General'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About GOAT',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAbout(context),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Account'),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                iconColor: theme.colorScheme.error,
                titleColor: theme.colorScheme.error,
                onTap: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
              ),

              const SizedBox(height: 32),

              // ── App version ──────────────────────────────────────────────
              Text(
                'GOAT v1.0.0',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GOAT',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 GOAT — Guide Of All Temples',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Discover, explore, and book visits to the most sacred temples across India.',
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
