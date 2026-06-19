import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goat/core/utils/result.dart';
import 'package:goat/features/temples/domain/entities/temple.dart';
import 'package:goat/features/temples/domain/entities/temple_category.dart';
import 'package:goat/features/temples/domain/repositories/temple_repository.dart';
import 'package:goat/features/temples/presentation/providers/temples_providers.dart';

class MockTempleRepository implements TempleRepository {
  final List<Temple> temples = [
    const Temple(
      id: '1',
      name: 'Shiva Temple',
      description: 'Test',
      imageUrl: '',
      latitude: 0,
      longitude: 0,
      city: 'Test City',
      state: 'Test State',
      category: TempleCategory.shaiva,
      rating: 4.5,
      reviewCount: 100,
      isVerified: true,
    ),
    const Temple(
      id: '2',
      name: 'Vishnu Temple',
      description: 'Test',
      imageUrl: '',
      latitude: 0,
      longitude: 0,
      city: 'Test City',
      state: 'Test State',
      category: TempleCategory.vaishnava,
      rating: 4.8,
      reviewCount: 200,
      isVerified: false,
    ),
  ];

  @override
  Future<Result<List<Temple>>> getTemples({TempleCategory? category}) async {
    if (category == null || category == TempleCategory.all) {
      return Ok(temples);
    }
    return Ok(temples.where((t) => t.category == category).toList());
  }

  @override
  Future<Result<Temple>> getTempleById(String id) async {
    final temple = temples.firstWhere((t) => t.id == id);
    return Ok(temple);
  }
}

void main() {
  group('templesProvider', () {
    test('returns all temples when category is all', () async {
      final container = ProviderContainer(
        overrides: [
          templeRepositoryProvider.overrideWithValue(MockTempleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final temples = await container.read(templesProvider.future);
      expect(temples.length, 2);
    });

    test('filters temples correctly by category', () async {
      final container = ProviderContainer(
        overrides: [
          templeRepositoryProvider.overrideWithValue(MockTempleRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Change category to Shaiva
      container.read(selectedCategoryProvider.notifier).state = TempleCategory.shaiva;

      final temples = await container.read(templesProvider.future);
      expect(temples.length, 1);
      expect(temples.first.name, 'Shiva Temple');
    });
  });
}
