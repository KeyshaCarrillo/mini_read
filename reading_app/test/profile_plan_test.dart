import 'package:flutter_test/flutter_test.dart';
import 'package:mini_read/features/library/data/models/book_model.dart';
import 'package:mini_read/features/library/domain/entities/plan_capabilities.dart';
import 'package:mini_read/features/library/domain/entities/reader_profile.dart';

void main() {
  group('PlanCapabilities', () {
    test('defines the production profile and device limits', () {
      expect(PlanCapabilities.free.maxProfiles, 4);
      expect(PlanCapabilities.free.maxDevices, 2);
      expect(PlanCapabilities.free.coinsDaily, 20);

      expect(PlanCapabilities.plus.maxProfiles, 6);
      expect(PlanCapabilities.plus.maxDevices, 3);
      expect(PlanCapabilities.plus.coinsDaily, 50);

      expect(PlanCapabilities.premium.maxProfiles, 8);
      expect(PlanCapabilities.premium.maxDevices, 5);
      expect(PlanCapabilities.premium.coinsDaily, 100);
    });
  });

  group('BookModel kids compatibility', () {
    test('normalizes kids audience and optional classification fields', () {
      final book = BookModel.fromJson({
        'id': 'kids-1',
        'title': 'Cuentos',
        'audience': 'kids',
        'ageGroup': '6-9',
        'bookType': 'Educativo',
        'tags': ['Animales', 'Aprender'],
      });

      expect(book.audience, 'kids');
      expect(book.ageGroup, '6-9');
      expect(book.bookType, 'Educativo');
      expect(book.tags, contains('Animales'));
    });
  });

  group('ReaderProfile PIN compatibility', () {
    test('keeps adult profile PIN settings through copyWith', () {
      const profile = ReaderProfile(
        id: 'adult-1',
        name: 'Keysha',
        ageGroup: 'Adultos',
        readingMood: 'Explorar',
        favoriteCategories: [],
        pinEnabled: true,
        pinCode: '1234',
        accentColor: 0xFFD4AF37,
      );

      final renamed = profile.copyWith(name: 'Keysha principal');

      expect(renamed.pinEnabled, isTrue);
      expect(renamed.pinCode, '1234');
    });
  });
}
