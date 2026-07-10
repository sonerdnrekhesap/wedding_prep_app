import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/app_settings_model.dart';
import '../models/item_model.dart';
import 'storage_service.dart';

const revenueCatAppleApiKey =
    String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
const revenueCatGoogleApiKey =
    String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');
const revenueCatEntitlementId =
    String.fromEnvironment('REVENUECAT_ENTITLEMENT_ID', defaultValue: 'pro');

enum PremiumProduct {
  monthly('premium_monthly', 'Aylık Premium'),
  sixMonths('premium_6months', '6 Aylık Hazırlık Paketi'),
  lifetime('premium_lifetime', 'Ömür Boyu Premium');

  const PremiumProduct(this.id, this.label);

  final String id;
  final String label;
}

enum PremiumAvailability {
  configured,
  missingApiKey,
  unavailableOnWeb,
  initializationFailed,
}

class PremiumService {
  PremiumService({required this.storage});

  final StorageService storage;
  bool _configured = false;
  PremiumAvailability availability = PremiumAvailability.missingApiKey;
  List<Package> packages = const [];

  bool get canPurchase => availability == PremiumAvailability.configured;

  Future<AppSettings> refreshEntitlement(AppSettings settings) async {
    if (!await _ensureConfigured()) {
      final next = settings.copyWith(isPremium: false);
      await storage.saveSettings(next);
      return next;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      final next = settings.copyWith(isPremium: _hasActiveEntitlement(info));
      await storage.saveSettings(next);
      await _loadOfferings();
      return next;
    } catch (error, stackTrace) {
      developer.log(
        'RevenueCat entitlement refresh failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return settings;
    }
  }

  Future<AppSettings> purchase(
    AppSettings settings,
    PremiumProduct product,
  ) async {
    if (!await _ensureConfigured()) return settings.copyWith(isPremium: false);
    await _loadOfferings();
    final package = _packageFor(product);
    if (package == null) return settings.copyWith(isPremium: false);
    try {
      final info = await Purchases.purchasePackage(package);
      final next = settings.copyWith(
        isPremium: _hasActiveEntitlement(info),
      );
      await storage.saveSettings(next);
      return next;
    } on PlatformException catch (error, stackTrace) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        developer.log(
          'RevenueCat purchase failed.',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return settings;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected purchase failure.',
        error: error,
        stackTrace: stackTrace,
      );
      return settings;
    }
  }

  Future<AppSettings> restorePurchases(AppSettings settings) async {
    if (!await _ensureConfigured()) return settings.copyWith(isPremium: false);
    try {
      final info = await Purchases.restorePurchases();
      final next = settings.copyWith(isPremium: _hasActiveEntitlement(info));
      await storage.saveSettings(next);
      return next;
    } catch (error, stackTrace) {
      developer.log(
        'RevenueCat restore failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return settings;
    }
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

  Future<bool> _ensureConfigured() async {
    if (kIsWeb) {
      availability = PremiumAvailability.unavailableOnWeb;
      return false;
    }
    if (_configured) return true;
    final key = defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS
        ? revenueCatAppleApiKey
        : revenueCatGoogleApiKey;
    if (key.isEmpty) {
      availability = PremiumAvailability.missingApiKey;
      return false;
    }
    try {
      await Purchases.configure(PurchasesConfiguration(key));
      _configured = true;
      availability = PremiumAvailability.configured;
      await _loadOfferings();
      return true;
    } catch (error, stackTrace) {
      availability = PremiumAvailability.initializationFailed;
      developer.log(
        'RevenueCat initialization failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      packages = offerings.current?.availablePackages ?? const [];
    } catch (error, stackTrace) {
      developer.log(
        'RevenueCat offerings load failed.',
        error: error,
        stackTrace: stackTrace,
      );
      packages = const [];
    }
  }

  Package? _packageFor(PremiumProduct product) {
    for (final package in packages) {
      if (package.storeProduct.identifier == product.id) return package;
    }
    return packages.isEmpty ? null : packages.first;
  }

  bool _hasActiveEntitlement(CustomerInfo info) {
    return info.entitlements.all[revenueCatEntitlementId]?.isActive == true;
  }
}
