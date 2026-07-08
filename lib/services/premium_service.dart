import '../models/app_settings_model.dart';
import '../models/item_model.dart';
import 'storage_service.dart';

enum PremiumProduct {
  monthly('premium_monthly', 'Aylık Premium'),
  sixMonths('premium_6months', '6 Aylık Hazırlık Paketi'),
  lifetime('premium_lifetime', 'Ömür Boyu Premium');

  const PremiumProduct(this.id, this.label);

  final String id;
  final String label;
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
