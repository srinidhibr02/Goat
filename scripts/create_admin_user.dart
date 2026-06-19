/// Create Admin User Script
///
/// Creates a Firebase Auth user and sets up their Firestore admin document
/// using the Firebase Auth & Firestore REST APIs directly — no gcloud needed.
///
/// Usage:
///   dart run scripts/create_admin_user.dart

import 'dart:convert';
import 'dart:io';

// ── Config ────────────────────────────────────────────────────────────────────
const _projectId  = 'goat-d3152';
const _apiKey     = 'AIzaSyDe3YrCmIlINVBWzJgNAq4ID8VbJEjP8sQ'; // Android Web API key
const _adminEmail    = 'admin@goat.app';
const _adminPassword = 'Admin@1234';
const _adminTempleId = '1'; // Change to a real temple ID if needed

void main() async {
  print('🔐 GOAT Admin User Creator');
  print('==========================\n');

  final client = HttpClient();

  // ── Step 1: Create or sign in the admin user ─────────────────────────────
  print('👤 Creating Firebase Auth user: $_adminEmail ...');
  final authResult = await _signUp(client);

  String? uid;
  String? idToken;

  if (authResult != null) {
    uid      = authResult['localId']  as String;
    idToken  = authResult['idToken']  as String;
    print('✅ Auth user created! UID: $uid\n');
  } else {
    // User might already exist — sign in instead
    print('⚠️  Trying sign-in (user may already exist)...');
    final signInResult = await _signIn(client);
    if (signInResult == null) {
      client.close();
      exit(1);
    }
    uid     = signInResult['localId'] as String;
    idToken = signInResult['idToken'] as String;
    print('✅ Signed in. UID: $uid\n');
  }

  // ── Step 2: Write Firestore admin document ────────────────────────────────
  print('📄 Writing Firestore document: users/$uid ...');
  final ok = await _writeFirestoreDocument(client, idToken!, uid!);
  client.close();

  if (!ok) exit(1);

  print('\n==========================');
  print('🎉 Admin user ready!');
  print('   Email:     $_adminEmail');
  print('   Password:  $_adminPassword');
  print('   Temple ID: $_adminTempleId');
  print('\nSign in to the goat_admin app with these credentials.');
}

// ── Firebase Auth REST ────────────────────────────────────────────────────────

Future<Map<String, dynamic>?> _signUp(HttpClient client) async {
  final url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey';
  try {
    final req = await client.openUrl('POST', Uri.parse(url));
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({
      'email': _adminEmail,
      'password': _adminPassword,
      'returnSecureToken': true,
    }));
    final res  = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;

    if (res.statusCode == 200) return json;

    // EMAIL_EXISTS → caller should try signIn
    if ((json['error']?['message'] as String? ?? '').contains('EMAIL_EXISTS')) {
      return null;
    }

    print('❌ Sign-up failed: ${json['error']?['message']}');
    return null;
  } catch (e) {
    print('❌ Error during sign-up: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> _signIn(HttpClient client) async {
  final url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey';
  try {
    final req = await client.openUrl('POST', Uri.parse(url));
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({
      'email': _adminEmail,
      'password': _adminPassword,
      'returnSecureToken': true,
    }));
    final res  = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;

    if (res.statusCode == 200) return json;

    print('❌ Sign-in failed: ${json['error']?['message']}');
    return null;
  } catch (e) {
    print('❌ Error during sign-in: $e');
    return null;
  }
}

// ── Firestore REST ────────────────────────────────────────────────────────────

Future<bool> _writeFirestoreDocument(
    HttpClient client, String idToken, String uid) async {
  final url =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users/$uid'
      '?updateMask.fieldPaths=role&updateMask.fieldPaths=adminTempleId';
  try {
    final req = await client.openUrl('PATCH', Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $idToken');
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({
      'fields': {
        'role':          {'stringValue': 'admin'},
        'adminTempleId': {'stringValue': _adminTempleId},
      }
    }));
    final res  = await req.close();
    final body = await res.transform(utf8.decoder).join();

    if (res.statusCode == 200) return true;

    print('❌ Firestore write failed (HTTP ${res.statusCode}):');
    print(body);
    return false;
  } catch (e) {
    print('❌ Error writing Firestore document: $e');
    return false;
  }
}
