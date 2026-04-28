import 'package:flutter_test/flutter_test.dart';
import 'package:goat/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    test('supports value equality', () {
      const user1 = AppUser(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      const user2 = AppUser(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      const user3 = AppUser(
        uid: '456',
        email: 'other@example.com',
        displayName: 'Other User',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('hashCode is consistent with equality', () {
      const user1 = AppUser(uid: '123');
      const user2 = AppUser(uid: '123');
      const user3 = AppUser(uid: '456');

      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1.hashCode, isNot(equals(user3.hashCode)));
    });

    test('toString contains relevant properties', () {
      const user = AppUser(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test',
      );

      final str = user.toString();
      expect(str, contains('123'));
      expect(str, contains('test@example.com'));
      expect(str, contains('Test'));
    });
  });
}
