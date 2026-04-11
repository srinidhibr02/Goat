import 'package:flutter/foundation.dart';

/// Represents an authenticated user in the domain layer.
///
/// Keeps no Firebase-specific types — pure Dart.
@immutable
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, displayName: $displayName)';
}
