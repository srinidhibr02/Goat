/// Firestore Temple Seeder
///
/// Seeds the Firestore 'temples' collection from the local JSON seed file.
///
/// Usage:
///   dart run scripts/seed_firestore.dart
///
/// Requirements:
///   - firebase-admin service account JSON at: scripts/service_account.json
///   - Dart packages: http, dart:convert
///
/// NOTE: This script uses the Firestore REST API directly so it can be run
/// without a Flutter environment. It does NOT require firebase_admin_dart.

import 'dart:convert';
import 'dart:io';

const _projectId = 'goat-d3152';
const _seedFile = 'assets/data/temples_seed.json';

/// Firestore REST endpoint
String _firestoreUrl(String collection, String docId) =>
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection/$docId';

void main() async {
  print('🚀 GOAT Firestore Seeder');
  print('========================\n');

  // ── Read seed file ───────────────────────────────────────────────────
  final file = File(_seedFile);
  if (!file.existsSync()) {
    print('❌ Seed file not found: $_seedFile');
    exit(1);
  }

  final List<dynamic> temples = jsonDecode(await file.readAsString());
  print('📄 Loaded ${temples.length} temples from seed file.\n');

  // ── Get access token via gcloud ──────────────────────────────────────
  print('🔑 Getting Firebase access token via gcloud...');
  final tokenResult = await Process.run(
    'gcloud',
    ['auth', 'print-access-token'],
  );
  if (tokenResult.exitCode != 0) {
    print('❌ Failed to get access token. Ensure gcloud is authenticated.');
    print(tokenResult.stderr);
    exit(1);
  }
  final token = (tokenResult.stdout as String).trim();
  print('✅ Got access token.\n');

  // ── Seed each temple ─────────────────────────────────────────────────
  final client = HttpClient();
  int success = 0;
  int failed = 0;

  for (final temple in temples) {
    final id = temple['id'].toString();
    final name = temple['name'];
    final url = _firestoreUrl('temples', id);

    try {
      final firestoreDoc = _toFirestoreDocument(temple);
      final request = await client.openUrl('PATCH', Uri.parse('$url?updateMask.fieldPaths=*'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(firestoreDoc));

      final response = await request.close();
      if (response.statusCode == 200) {
        print('  ✅ [$id] $name');
        success++;
      } else {
        final body = await response.transform(utf8.decoder).join();
        print('  ❌ [$id] $name — HTTP ${response.statusCode}: $body');
        failed++;
      }
    } catch (e) {
      print('  ❌ [$id] $name — Error: $e');
      failed++;
    }
  }

  client.close();

  print('\n========================');
  print('✅ Seeded: $success  ❌ Failed: $failed');

  // ── Deploy Firestore rules ────────────────────────────────────────────
  if (File('firestore.rules').existsSync()) {
    print('\n📋 Deploying Firestore security rules...');
    final rulesResult = await Process.run(
      'firebase',
      ['deploy', '--only', 'firestore:rules', '--project', _projectId],
    );
    if (rulesResult.exitCode == 0) {
      print('✅ Firestore rules deployed successfully.');
    } else {
      print('⚠️  Rules deploy failed (you can deploy manually):');
      print('   firebase deploy --only firestore:rules --project $_projectId');
    }
  }
}

/// Converts a plain Dart map to a Firestore REST API document format.
Map<String, dynamic> _toFirestoreDocument(Map<String, dynamic> data) {
  return {
    'fields': data.map((key, value) {
      return MapEntry(key, _toFirestoreValue(value));
    }),
  };
}

dynamic _toFirestoreValue(dynamic value) {
  if (value is String) return {'stringValue': value};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  if (value is List) {
    return {
      'arrayValue': {
        'values': value.map(_toFirestoreValue).toList(),
      },
    };
  }
  if (value is Map) return {'mapValue': _toFirestoreDocument(value.cast())};
  return {'nullValue': null};
}
