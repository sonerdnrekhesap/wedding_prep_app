import '../models/app_settings_model.dart';
import '../models/item_model.dart';
import 'storage_service.dart';

enum PremiumProduct {
  monthly(
    id: 'premium_monthly',
    label: 'Aylık Premium',
    priceLabel: 'TRY 49,99',
    cadenceLabel: 'aylık',
    badge: 'Planlı',
    pitch: 'Abonelik doğrulaması tamamlanınca açılacak esnek plan.',
    isLaunchReady: false,
  ),
  sixMonths(
    id: 'premium_6months',
    label: '6 Aylık Hazırlık Paketi',
    priceLabel: 'TRY 199,99',
    cadenceLabel: 'tek ödeme',
    badge: 'Planlı',
    pitch: 'Nişan-düğün arası hazırlık dönemi için planlanan paket.',
    isLaunchReady: false,
  ),
  lifetime(
    id: 'premium_lifetime',
    label: 'Ömür Boyu Premium',
    priceLabel: 'TRY 349,99',
    cadenceLabel: 'tek ödeme',
    badge: 'İlk release',
    pitch:
        'Tek ödeme ile reklamsız planlama, premium özetler ve arşiv kotasını aç.',
    isRecommended: true,
  );

  const PremiumProduct({
    required this.id,
    required this.label,
    required this.priceLabel,
    required this.cadenceLabel,
    required this.badge,
    required this.pitch,
    this.isRecommended = false,
    this.isLaunchReady = true,
  });

  final String id;
  final String label;
  final String priceLabel;
  final String cadenceLabel;
  final String badge;
  final String pitch;
  final bool isRecommended;
  final bool isLaunchReady;
}

class PremiumCatalog {
  const PremiumCatalog._();

  static const heroPromise =
      'Daha az panik, daha net plan: reklamsız takip, akıllı haftalık öncelikler ve premium hazırlık özeti.';

  static const freeKeeps = [
    'Checklist ve temel bütçe takibi',
    'Davetli listesi ve CSV paylaşımı',
    'Haftalık öncelik önerileri',
  ];

  static const premiumBenefits = [
    'Reklamsız planlama',
    'Hazırlık listesi ve bütçe özeti CSV export',
    'Premium hazırlık özeti ve paylaşım kartları',
    'Daha derin bütçe ve eksik analizleri',
    '10 fotoğraf sınırı olmadan arşiv alanı',
    'Yeni aile paylaşımı özelliklerine erken erişim',
  ];

  static PremiumProduct get recommended => PremiumProduct.values.firstWhere(
        (product) => product.isRecommended,
        orElse: () => PremiumProduct.sixMonths,
      );

  static Set<String> get productIds => {
        for (final product in PremiumProduct.values)
          if (product.isLaunchReady) product.id,
      };

  static List<PremiumProduct> get launchProducts => PremiumProduct.values
      .where((product) => product.isLaunchReady)
      .toList(growable: false);
}

class PremiumService {
  const PremiumService({required this.storage});

  final StorageService storage;

  Future<AppSettings> purchaseMock(
    AppSettings settings,
    PremiumProduct product,
  ) async {
    final next = settings.copyWith(isPremium: true);
    await storage.saveSettings(next);
    return next;
  }

  Future<AppSettings> restorePurchases(AppSettings settings) async {
    await storage.saveSettings(settings);
    return settings;
  }

  Future<AppSettings> activateFromStore(AppSettings settings) async {
    final next = settings.copyWith(isPremium: true);
    await storage.saveSettings(next);
    return next;
  }

  Future<AppSettings> disableMockPremium(AppSettings settings) async {
    final next = settings.copyWith(isPremium: false);
    await storage.saveSettings(next);
    return next;
  }

  bool canAddPhoto(AppSettings settings, List<PrepItem> items) {
    return settings.isPremium || usedPhotoSlots(items) < 10;
  }

  int usedPhotoSlots(List<PrepItem> items) {
    var count = 0;
    for (final item in items) {
      if (item.inspirationImagePath?.isNotEmpty == true) count += 1;
      if (item.productImagePath?.isNotEmpty == true) count += 1;
      if (item.receiptImagePath?.isNotEmpty == true) count += 1;
    }
    return count;
  }
}
