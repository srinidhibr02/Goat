import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goat/features/temples/domain/entities/temple.dart';
import 'package:goat/features/temples/domain/entities/temple_category.dart';
import 'package:goat/features/temples/presentation/widgets/temple_card.dart';

void main() {
  testWidgets('TempleCard displays temple name and location', (WidgetTester tester) async {
    const temple = Temple(
      id: '1',
      name: 'Test Temple',
      description: 'A beautiful temple.',
      imageUrl: 'https://example.com/image.jpg',
      latitude: 0.0,
      longitude: 0.0,
      city: 'Test City',
      state: 'Test State',
      category: TempleCategory.shaiva,
      rating: 4.8,
      reviewCount: 100,
      isVerified: true,
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TempleCard(temple: temple),
          ),
        ),
      ),
    );

    // Wait for initial render
    await tester.pumpAndSettle();

    expect(find.text('Test Temple'), findsOneWidget);
    expect(find.text('Test City'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('✓ Verified'), findsOneWidget);
  });
}
