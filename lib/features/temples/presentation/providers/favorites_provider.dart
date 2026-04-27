import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_paths.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ── Favorites State ──────────────────────────────────────────────────────────

/// Holds the set of favorited temple IDs.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(ref),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  StreamSubscription? _sub;
  String? _uid;
  bool _isFirebaseConfigured = false;

  FavoritesNotifier(this._ref) : super({}) {
    try {
      Firebase.app();
      _isFirebaseConfigured = true;
    } catch (_) {}

    // Listen to Auth State
    _ref.listen(authStateProvider, (prev, next) {
      final user = next.valueOrNull;
      if (user?.uid != _uid) {
        _uid = user?.uid;
        _initFirestoreSync();
      }
    });
  }

  void _initFirestoreSync() {
    _sub?.cancel();
    _sub = null;

    if (_uid == null) {
      state = {};
      return;
    }

    if (!_isFirebaseConfigured) return;

    final docRef = FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(_uid);

    _sub = docRef.snapshots().listen((doc) {
      if (doc.exists) {
        final favs = List<String>.from(doc.data()?['favorites'] ?? []);
        state = favs.toSet();
      } else {
        state = {};
      }
    });
  }

  void toggle(String templeId) {
    if (state.contains(templeId)) {
      state = {...state}..remove(templeId);
    } else {
      state = {...state, templeId};
    }
    
    // Sync to Firestore
    if (_isFirebaseConfigured && _uid != null) {
      FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(_uid)
          .set({
        'favorites': state.toList(),
      }, SetOptions(merge: true));
    }
  }

  bool isFavorite(String templeId) => state.contains(templeId);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ── Derived provider ─────────────────────────────────────────────────────────

/// Returns `true` if the given temple is in the user's favorites.
final isFavoriteProvider = Provider.family<bool, String>(
  (ref, templeId) => ref.watch(favoritesProvider).contains(templeId),
);
