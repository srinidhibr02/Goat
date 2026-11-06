import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/domain/entities/feed_post.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../../../temples/domain/entities/temple.dart';
import '../../../temples/presentation/providers/temples_providers.dart';

// ── Create Post Page ──────────────────────────────────────────────────────────

/// Full-screen form for temple admins to publish Events & Updates posts.
///
/// Writes directly to the Firestore `feed` collection.
/// Only reachable from the Profile page when `isAdminProvider` is true.
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  Temple? _selectedTemple;
  FeedPostType _type = FeedPostType.news;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  DateTime? _eventDate;

  bool _loading = false;

  static const _types = FeedPostType.values;

  static const _typeLabels = {
    FeedPostType.news: 'News',
    FeedPostType.event: 'Event',
    FeedPostType.festival: 'Festival',
    FeedPostType.announcement: 'Announcement',
  };

  static const _typeIcons = {
    FeedPostType.news: Icons.newspaper_rounded,
    FeedPostType.event: Icons.event_rounded,
    FeedPostType.festival: Icons.celebration_rounded,
    FeedPostType.announcement: Icons.campaign_rounded,
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  // ── Publish ─────────────────────────────────────────────────────────────────

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemple == null) {
      _showSnack('Please select a temple.');
      return;
    }
    if (_type == FeedPostType.event || _type == FeedPostType.festival) {
      if (_eventDate == null) {
        _showSnack('Please select an event date.');
        return;
      }
    }

    setState(() => _loading = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      final doc = FirebaseFirestore.instance.collection('feed').doc();

      await doc.set({
        'templeId': _selectedTemple!.id,
        'templeName': _selectedTemple!.name,
        'templeImageUrl': _selectedTemple!.imageUrl,
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'type': _type.name,
        'publishedAt': FieldValue.serverTimestamp(),
        'eventDate':
            _eventDate != null ? Timestamp.fromDate(_eventDate!) : null,
        'imageUrl': _imageCtrl.text.trim().isEmpty
            ? null
            : _imageCtrl.text.trim(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'authorUid': user?.uid,
      });

      // Refresh the feed so the new post appears immediately
      ref.read(feedPostsProvider.notifier).refresh();

      if (mounted) {
        _showSnack('Post published! 🎉', success: true);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) context.pop();
      }
    } on FirebaseException catch (e) {
      _showSnack('Failed: ${e.message}');
    } catch (e) {
      _showSnack('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Event date picker ────────────────────────────────────────────────────────

  Future<void> _pickEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templesAsync = ref.watch(templesProvider);
    final temples = templesAsync.valueOrNull ?? [];
    final needsEventDate =
        _type == FeedPostType.event || _type == FeedPostType.festival;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.saffron,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onPressed: _loading ? null : _publish,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Publish',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── Temple selector ───────────────────────────────────────────
            _SectionLabel('Temple'),
            const SizedBox(height: 8),
            DropdownButtonFormField<Temple>(
              value: _selectedTemple,
              decoration: _inputDecoration('Select a temple…'),
              isExpanded: true,
              items: temples.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.name,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                );
              }).toList(),
              onChanged: (t) => setState(() => _selectedTemple = t),
              validator: (_) =>
                  _selectedTemple == null ? 'Select a temple' : null,
            ),
            const SizedBox(height: 20),

            // ── Post type ─────────────────────────────────────────────────
            _SectionLabel('Post Type'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final selected = t == _type;
                return ChoiceChip(
                  avatar: Icon(_typeIcons[t],
                      size: 16,
                      color: selected ? Colors.white : AppColors.saffron),
                  label: Text(_typeLabels[t]!),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _type = t;
                    if (t != FeedPostType.event &&
                        t != FeedPostType.festival) {
                      _eventDate = null;
                    }
                  }),
                  selectedColor: AppColors.saffron,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────────────
            _SectionLabel('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDecoration('e.g. Brahmotsavam 2025 Schedule'),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Title is required';
                if (v.trim().length < 5) return 'Title too short';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Body ──────────────────────────────────────────────────────
            _SectionLabel('Message / Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyCtrl,
              decoration: _inputDecoration(
                  'Write the full details for devotees…'),
              maxLines: 5,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Body is required';
                if (v.trim().length < 10) return 'Body too short';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Event date (conditional) ───────────────────────────────────
            if (needsEventDate) ...[
              _SectionLabel('Event Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickEventDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          color: AppColors.saffron, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _eventDate == null
                            ? 'Tap to choose event date'
                            : DateFormat('d MMMM yyyy').format(_eventDate!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _eventDate == null
                              ? theme.colorScheme.onSurfaceVariant
                              : null,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Image URL (optional) ───────────────────────────────────────
            _SectionLabel('Image URL (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageCtrl,
              decoration: _inputDecoration('https://…'),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 8),
            Text(
              'Paste a direct link to an image (JPG / PNG). '
              'Leave blank for a text-only post.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // ── Publish button (bottom) ────────────────────────────────────
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _loading ? null : _publish,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _loading ? 'Publishing…' : 'Publish Post',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
    );
  }
}

