import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

// ── Admin role check ──────────────────────────────────────────────────────────

/// `true` when the signed-in user has `role == "admin"` in Firestore.
///
/// To grant admin access, set the field on the user document in Firestore:
/// ```
///   users/{uid}  →  { "role": "admin" }
/// ```
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['role'] == 'admin';
  } catch (_) {
    return false;
  }
});

