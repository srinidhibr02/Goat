import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

/// Help & Support page — FAQ accordion + contact channels.
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Contact cards ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email Us',
                  sublabel: 'support@goat-app.in',
                  color: const Color(0xFF6C63FF),
                  onTap: () => _launchEmail(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'WhatsApp',
                  sublabel: 'Chat with us',
                  color: const Color(0xFF25D366),
                  onTap: () => _launchWhatsApp(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── FAQ ─────────────────────────────────────────────────────────
          Text('Frequently Asked Questions',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          const _FaqItem(
            question: 'How do I book a temple visit?',
            answer:
                'Browse temples on the Home or Explore tab, tap a temple to open '
                'its detail page, then tap "Book a Visit". Choose your preferred '
                'date and darshan time slot, review the summary, and confirm.',
          ),
          const _FaqItem(
            question: 'Can I cancel a booking?',
            answer:
                'Yes. Go to the Bookings tab, find your booking, and tap the '
                'cancel icon on the right. Confirm in the dialog. Cancelled '
                'bookings are moved to the "Past & Cancelled" section.',
          ),
          const _FaqItem(
            question: 'How do I save favourite temples?',
            answer:
                'Tap the ♡ heart icon on any temple card or on the temple detail '
                'page. Your favourites are synced to your account and accessible '
                'from the Favourites tab in the bottom navigation.',
          ),
          const _FaqItem(
            question: 'How do I change my profile photo?',
            answer:
                'Go to the Profile tab and tap your avatar (or the edit icon). '
                'Choose "Camera" or "Gallery" to pick a new photo. It is uploaded '
                'securely and updated across all your devices.',
          ),
          const _FaqItem(
            question: 'Why are some temples not showing?',
            answer:
                'Temple listings are curated. If a temple is missing, you can '
                'suggest it by emailing us at support@goat-app.in with the temple '
                'name, city, and state.',
          ),
          const _FaqItem(
            question: 'How do I turn off notifications?',
            answer:
                'Go to Profile → Notifications. You can toggle General, Festivals '
                '& Events, and Booking Reminder notifications independently.',
          ),
          const _FaqItem(
            question: 'Is my data safe?',
            answer:
                'All data is stored on Google Firebase with enterprise-grade '
                'encryption in transit and at rest. We never sell your data to '
                'third parties. See our Privacy Policy for full details.',
          ),
          const _FaqItem(
            question: 'How do I delete my account?',
            answer:
                'Email us at support@goat-app.in with the subject "Delete Account" '
                'from your registered email address. We will process the deletion '
                'within 30 days.',
          ),

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 16),

          Center(
            child: Text(
              'Still need help? We\'re here for you 🙏',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _launchEmail(context),
              icon: const Icon(Icons.support_agent_outlined, size: 18),
              label: const Text('Contact Support'),
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
      query: 'subject=GOAT%20App%20Support',
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

  Future<void> _launchWhatsApp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/919999999999?text=Hi%20GOAT%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp is not installed')),
        );
      }
    }
  }
}

// ── Contact card ──────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color, fontSize: 13)),
            const SizedBox(height: 2),
            Text(sublabel,
                style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── FAQ accordion item ────────────────────────────────────────────────────────

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded
              ? AppColors.saffron.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
        ),
        color: _expanded
            ? AppColors.saffron.withValues(alpha: 0.04)
            : theme.colorScheme.surface,
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: _expanded
                            ? AppColors.saffron
                            : theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
