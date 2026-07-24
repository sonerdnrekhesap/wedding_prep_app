import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/services/premium_service.dart';

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
}
