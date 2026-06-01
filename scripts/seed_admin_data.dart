/// Seed Temple Admin Data Script
///
/// Authenticates as admin@goat.app and seeds the Firestore database with
/// sample services, transactions, and commission configurations for temple ID '1'.
///
/// Usage:
///   dart run scripts/seed_admin_data.dart

import 'dart:convert';
import 'dart:io';

const _projectId = 'goat-d3152';
const _apiKey = 'AIzaSyDe3YrCmIlINVBWzJgNAq4ID8VbJEjP8sQ';
const _adminEmail = 'admin@goat.app';
const _adminPassword = 'Admin@1234';

void main() async {
  print('📊 GOAT Admin Firestore Seeder');
  print('==============================\n');

  final client = HttpClient();

  // 1. Authenticate to get ID token
  print('🔑 Authenticating as $_adminEmail...');
  final authData = await _signIn(client);
  if (authData == null) {
    print('❌ Authentication failed. Make sure you ran scripts/create_admin_user.dart first.');
    client.close();
    exit(1);
  }

  final idToken = authData['idToken'] as String;
  final uid = authData['localId'] as String;
  print('✅ Authenticated. UID: $uid\n');

  // 2. Write config/commission
  print('📈 Seeding config/commission...');
  final configOk = await _writeCommissionConfig(client, idToken);
  if (configOk) {
    print('  ✅ Commission rate set to 8% (0.08)\n');
  } else {
    print('  ❌ Failed to seed commission rate\n');
  }

  // 3. Write temples/1/services
  print('🛠️ Seeding active services under temples/1/services...');
  final services = [
    {'id': 'special_darshan', 'name': 'Special Darshan (VIP)', 'isActive': true},
    {'id': 'archana', 'name': 'Sahasranama Archana', 'isActive': true},
    {'id': 'kalyanotsavam', 'name': 'Sri Venkateswara Kalyanotsavam', 'isActive': true},
    {'id': 'prasadam', 'name': 'Laddu Prasadam (Bulk)', 'isActive': true},
    {'id': 'homam', 'name': 'Chandi Homam', 'isActive': false}, // inactive
  ];

  int servicesSeeded = 0;
  for (final service in services) {
    final ok = await _writeService(client, idToken, service['id'] as String, service['name'] as String, service['isActive'] as bool);
    if (ok) {
      print('  ✅ Service: ${service['name']}');
      servicesSeeded++;
    } else {
      print('  ❌ Service: ${service['name']}');
    }
  }
  print('✅ Services seeded: $servicesSeeded / ${services.length}\n');

  // 4. Write transactions
  print('💸 Seeding sample transactions under /transactions...');
  final now = DateTime.now().toUtc();
  final txs = [
    // Donations
    {
      'id': 'tx_don_1',
      'type': 'donation',
      'amount': 25000.0,
      'timestamp': now.subtract(const Duration(days: 2)).toIso8601String(),
      'description': 'Donation for Anna Prasadam scheme'
    },
    {
      'id': 'tx_don_2',
      'type': 'donation',
      'amount': 10000.0,
      'timestamp': now.subtract(const Duration(days: 5)).toIso8601String(),
      'description': 'General temple development fund'
    },
    {
      'id': 'tx_don_3',
      'type': 'donation',
      'amount': 50000.0,
      'timestamp': now.subtract(const Duration(days: 12)).toIso8601String(),
      'description': 'Golden chariot restoration offering'
    },
    {
      'id': 'tx_don_4',
      'type': 'donation',
      'amount': 5000.0,
      'timestamp': now.subtract(const Duration(days: 18)).toIso8601String(),
      'description': 'Donation for cow protection (Goshala)'
    },
    // Bookings
    {
      'id': 'tx_bk_1',
      'type': 'booking',
      'amount': 1500.0,
      'timestamp': now.subtract(const Duration(hours: 4)).toIso8601String(),
      'description': 'VIP Special Darshan Booking'
    },
    {
      'id': 'tx_bk_2',
      'type': 'booking',
      'amount': 3000.0,
      'timestamp': now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
      'description': 'Sri Venkateswara Kalyanotsavam Booking'
    },
    {
      'id': 'tx_bk_3',
      'type': 'booking',
      'amount': 500.0,
      'timestamp': now.subtract(const Duration(days: 3)).toIso8601String(),
      'description': 'Sahasranama Archana Booking'
    },
    {
      'id': 'tx_bk_4',
      'type': 'booking',
      'amount': 1000.0,
      'timestamp': now.subtract(const Duration(days: 4)).toIso8601String(),
      'description': 'Bulk Laddu Prasadam Booking'
    },
    {
      'id': 'tx_bk_5',
      'type': 'booking',
      'amount': 1500.0,
      'timestamp': now.subtract(const Duration(days: 7)).toIso8601String(),
      'description': 'VIP Special Darshan Booking'
    },
    {
      'id': 'tx_bk_6',
      'type': 'booking',
      'amount': 1500.0,
      'timestamp': now.subtract(const Duration(days: 10)).toIso8601String(),
      'description': 'VIP Special Darshan Booking'
    },
    {
      'id': 'tx_bk_7',
      'type': 'booking',
      'amount': 3000.0,
      'timestamp': now.subtract(const Duration(days: 15)).toIso8601String(),
      'description': 'Sri Venkateswara Kalyanotsavam Booking'
    },
    {
      'id': 'tx_bk_8',
      'type': 'booking',
      'amount': 500.0,
      'timestamp': now.subtract(const Duration(days: 20)).toIso8601String(),
      'description': 'Sahasranama Archana Booking'
    },
    {
      'id': 'tx_bk_9',
      'type': 'booking',
      'amount': 1500.0,
      'timestamp': now.subtract(const Duration(days: 25)).toIso8601String(),
      'description': 'VIP Special Darshan Booking'
    },
    {
      'id': 'tx_bk_10',
      'type': 'booking',
      'amount': 1000.0,
      'timestamp': now.subtract(const Duration(days: 28)).toIso8601String(),
      'description': 'Bulk Laddu Prasadam Booking'
    },
  ];

  int txsSeeded = 0;
  for (final tx in txs) {
    final ok = await _writeTransaction(client, idToken, tx);
    if (ok) {
      print('  ✅ Tx [${tx['id']}]: ${tx['type']} - ₹${tx['amount']}');
      txsSeeded++;
    } else {
      print('  ❌ Tx [${tx['id']}]');
    }
  }
  print('✅ Transactions seeded: $txsSeeded / ${txs.length}\n');

  client.close();
  print('==============================');
  print('🎉 All admin testing data is seeded!');
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
    final res = await req.close();
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

Future<bool> _writeCommissionConfig(HttpClient client, String idToken) async {
  final url = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/config/commission'
      '?updateMask.fieldPaths=rate';
  try {
    final req = await client.openUrl('PATCH', Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $idToken');
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({
      'fields': {
        'rate': {'doubleValue': 0.08},
      }
    }));
    final res = await req.close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future<bool> _writeService(HttpClient client, String idToken, String id, String name, bool isActive) async {
  final url = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/temples/1/services/$id'
      '?updateMask.fieldPaths=name&updateMask.fieldPaths=isActive';
  try {
    final req = await client.openUrl('PATCH', Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $idToken');
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({
      'fields': {
        'name': {'stringValue': name},
        'isActive': {'booleanValue': isActive},
      }
    }));
    final res = await req.close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future<bool> _writeTransaction(HttpClient client, String idToken, Map<String, dynamic> tx) async {
  final url = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/transactions/${tx['id']}'
      '?updateMask.fieldPaths=templeId'
      '&updateMask.fieldPaths=type'
      '&updateMask.fieldPaths=amount'
      '&updateMask.fieldPaths=timestamp'
      '&updateMask.fieldPaths=description';
  try {
    final req = await client.openUrl('PATCH', Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $idToken');
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({
      'fields': {
        'templeId': {'stringValue': '1'},
        'type': {'stringValue': tx['type'] as String},
        'amount': {'doubleValue': tx['amount'] as double},
        'timestamp': {'timestampValue': tx['timestamp'] as String},
        'description': {'stringValue': tx['description'] as String},
      }
    }));
    final res = await req.close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}
