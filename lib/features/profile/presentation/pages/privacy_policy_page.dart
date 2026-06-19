import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

/// Static Privacy Policy page with key sections and an external link.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _lastUpdated = 'June 2025';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.saffron.withValues(alpha: 0.08),
              border: Border.all(
                  color: AppColors.saffron.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined,
                    color: AppColors.saffron, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GOAT Privacy Policy',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('Last updated: $_lastUpdated',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _PolicySection(
            title: '1. Information We Collect',
            content:
                'When you create an account, we collect your name, email address, and profile photo. '
                'When you book a temple visit, we store your booking details. '
                'We also collect anonymous usage analytics to improve the app experience.',
          ),
          _PolicySection(
            title: '2. How We Use Your Information',
            content:
                'Your information is used to:\n'
                '• Provide and personalise the GOAT experience\n'
                '• Send booking confirmations and reminders\n'
                '• Notify you of festivals and events at your favourite temples\n'
                '• Improve app performance through anonymised analytics',
          ),
          _PolicySection(
            title: '3. Data Storage & Security',
            content:
                'All data is securely stored on Google Firebase infrastructure. '
                'We use Firebase Authentication, Firestore, and Storage — all protected '
                'by Google\'s enterprise-grade security. Your data is encrypted in transit '
                'and at rest.',
          ),
          _PolicySection(
            title: '4. Third-Party Services',
            content:
                'We use the following third-party services:\n'
                '• Google Firebase (Auth, Firestore, Storage, Analytics, Crashlytics)\n'
                '• Google Sign-In\n'
                '• OpenStreetMap (map tiles — no account required)\n\n'
                'Each service has its own privacy policy.',
          ),
          _PolicySection(
            title: '5. Your Rights',
            content:
                'You may request deletion of your account and all associated data at any time '
                'by contacting us at support@goat-app.in. We will process your request within 30 days.',
          ),
          _PolicySection(
            title: '6. Children\'s Privacy',
            content:
                'GOAT is not directed at children under 13. We do not knowingly collect '
                'personal information from children under 13.',
          ),
          _PolicySection(
            title: '7. Changes to This Policy',
            content:
                'We may update this Privacy Policy from time to time. We will notify you '
                'of any significant changes via in-app notification or email.',
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Contact / full policy link ──────────────────────────────────
          Center(
            child: Column(
              children: [
                Text('Questions about your privacy?',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _launchEmail(context),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Contact Us'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@goat-app.in',
      query: 'subject=Privacy%20Query%20%E2%80%94%20GOAT%20App',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open mail client')),
        );
      }
    }
  }
}

// ── Policy section widget ─────────────────────────────────────────────────────

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(content,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
        ],
      ),
    );
  }
}
