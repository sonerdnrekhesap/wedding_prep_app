import '../models/app_settings_model.dart';
import '../models/item_model.dart';
import 'storage_service.dart';

enum PremiumProduct {
  monthly(
    id: 'premium_monthly',
    label: 'Aylik Premium',
    priceLabel: 'TRY 49,99',
    cadenceLabel: 'aylik',
    badge: 'Esnek',
    pitch: 'Kisa sureli planlayanlar icin.',
  ),
  sixMonths(
    id: 'premium_6months',
    label: '6 Aylik Hazirlik Paketi',
    priceLabel: 'TRY 199,99',
    cadenceLabel: 'tek odeme',
    badge: 'En mantikli',
    pitch: 'Nisan-dugun arasi tum hazirlik donemi icin.',
    isRecommended: true,
  ),
  lifetime(
    id: 'premium_lifetime',
    label: 'Omur Boyu Premium',
    priceLabel: 'TRY 349,99',
    cadenceLabel: 'tek odeme',
    badge: 'En iyi deger',
    pitch: 'Kardes, aile ve sonraki etkinliklerde de kullan.',
  );

  const PremiumProduct({
    required this.id,
    required this.label,
    required this.priceLabel,
    required this.cadenceLabel,
    required this.badge,
    required this.pitch,
    this.isRecommended = false,
  });

  final String id;
  final String label;
  final String priceLabel;
  final String cadenceLabel;
  final String badge;
  final String pitch;
  final bool isRecommended;
}

class PremiumCatalog {
  const PremiumCatalog._();

  static const heroPromise =
      'Daha az panik, daha net plan: reklamsiz takip, akilli haftalik plan ve profesyonel export iskeleti.';

  static const freeKeeps = [
    'Checklist ve temel butce takibi',
    'Davetli listesi ve CSV paylasimi',
    'Haftalik oncelik onerileri',
  ];

  static const premiumBenefits = [
    'Reklamsiz planlama',
    'PDF/Excel export iskeleti',
    'Detayli butce ve eksik analizleri',
    'Sinirsiz fotograf/fis arsivi',
    'Premium ozet kartlari',
    'Partner senkronizasyonu icin hazir altyapi',
  ];

  static PremiumProduct get recommended => PremiumProduct.values.firstWhere(
        (product) => product.isRecommended,
        orElse: () => PremiumProduct.sixMonths,
      );

  static Set<String> get productIds => {
        for (final product in PremiumProduct.values) product.id,
      };
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
