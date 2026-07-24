import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/models/app_settings_model.dart';
import 'package:wedding_prep_app/models/item_model.dart';
import 'package:wedding_prep_app/services/premium_service.dart';
import 'package:wedding_prep_app/services/storage_service.dart';

void main() {
  group('PremiumCatalog', () {
    test('has one launch-ready recommended product', () {
      final recommended = PremiumProduct.values
          .where((product) => product.isRecommended)
          .toList();

      expect(recommended, hasLength(1));
      expect(PremiumCatalog.recommended, PremiumProduct.lifetime);
      expect(PremiumCatalog.recommended.id, 'premium_lifetime');
    });

    test('exposes only launch-ready product ids to the store layer', () {
      expect(
        PremiumCatalog.productIds,
        {
          'premium_lifetime',
        },
      );
    });

    test('keeps free value separate from premium value', () {
      expect(PremiumCatalog.freeKeeps, isNotEmpty);
      expect(
        PremiumCatalog.premiumBenefits,
        contains('Reklamsız planlama'),
      );
      expect(
        PremiumCatalog.premiumBenefits,
        contains('Premium hazırlık özeti ve paylaşım kartları'),
      );
    });
  });

  group('PremiumService photo quota', () {
    test('allows free users below 10 photo slots', () {
      final items = _itemsWithPhotoSlots(9);

      expect(
        PremiumService(storage: _FakeStorage()).canAddPhoto(
          const AppSettings(),
          items,
        ),
        isTrue,
      );
    });

    test('locks free users at 10 photo slots', () {
      final items = _itemsWithPhotoSlots(10);

      expect(
        PremiumService(storage: _FakeStorage()).canAddPhoto(
          const AppSettings(),
          items,
        ),
        isFalse,
      );
    });

    test('keeps photo archive unlimited for premium users', () {
      final items = _itemsWithPhotoSlots(12);

      expect(
        PremiumService(storage: _FakeStorage()).canAddPhoto(
          const AppSettings(isPremium: true),
          items,
        ),
        isTrue,
      );
    });
  });
}

List<PrepItem> _itemsWithPhotoSlots(int count) {
  return [
    for (var index = 0; index < count; index += 1)
      PrepItem(
        id: 'item-$index',
        title: 'Item $index',
        mainCategory: MainCategory.ceyiz,
        subCategory: 'Test',
        priority: ItemPriority.necessary,
        inspirationImagePath: 'photo-$index.jpg',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
  ];
}

class _FakeStorage extends StorageService {
  _FakeStorage();
}
