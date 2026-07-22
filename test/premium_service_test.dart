import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_prep_app/services/premium_service.dart';

void main() {
  group('PremiumCatalog', () {
    test('has one recommended preparation-period product', () {
      final recommended = PremiumProduct.values
          .where((product) => product.isRecommended)
          .toList();

      expect(recommended, hasLength(1));
      expect(PremiumCatalog.recommended, PremiumProduct.sixMonths);
      expect(PremiumCatalog.recommended.id, 'premium_6months');
    });

    test('keeps free value separate from premium value', () {
      expect(PremiumCatalog.freeKeeps, isNotEmpty);
      expect(PremiumCatalog.premiumBenefits, contains('Reklamsiz planlama'));
      expect(
        PremiumCatalog.premiumBenefits,
        contains('PDF/Excel export iskeleti'),
      );
    });
  });
}
