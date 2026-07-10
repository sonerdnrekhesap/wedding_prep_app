import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import '../models/lead_request_model.dart';
import 'ad_service.dart';
import 'analytics_service.dart';
import 'export_service.dart';
import 'notification_service.dart';
import 'photo_storage_service.dart';
import 'premium_service.dart';
import 'storage_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.storage,
    required this.ads,
  });

  final StorageService storage;
  final AdService ads;
  final PhotoStorageService photoStorage = const PhotoStorageService();
  final AnalyticsService analytics = const AnalyticsService();
  final NotificationService notifications = NotificationService();
  final _uuid = const Uuid();
  late final PremiumService premium = PremiumService(storage: storage);

  bool isLoading = true;
  bool recoveredFromStartupError = false;
  String? startupMessage;
  AppSettings settings = const AppSettings();
  List<PrepItem> items = [];
  List<Guest> guests = [];
  List<LeadRequest> leads = [];

  Future<void> load() async {
    isLoading = true;
    recoveredFromStartupError = false;
    startupMessage = null;
    notifyListeners();

    try {
      await storage.initialize();
      settings = await storage.loadSettings();
      items = await storage.loadItems();
      guests = await storage.loadGuests();
      leads = await storage.loadLeads();
    } catch (error, stackTrace) {
      recoveredFromStartupError = true;
      startupMessage =
          'Bazı yerel veriler okunamadı. Uygulama güvenli modda açıldı.';
      developer.log(
        'Application startup recovered from a storage failure.',
        error: error,
        stackTrace: stackTrace,
      );
      settings = const AppSettings();
      items = [];
      guests = [];
      leads = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }

    unawaited(_refreshPremiumAndAds());
  }

  Future<void> retryStartup() => load();

  void continueAfterStartupRecovery() {
    recoveredFromStartupError = false;
    notifyListeners();
  }

  Future<void> _refreshPremiumAndAds() async {
    try {
      settings = await premium.refreshEntitlement(settings);
      ads.setPremium(settings.isPremium);
      notifyListeners();
    } catch (error, stackTrace) {
      developer.log(
        'Premium refresh failed during startup.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      await ads.initialize();
    } catch (error, stackTrace) {
      developer.log(
        'Ad initialization failed without blocking startup.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> saveSettings(AppSettings next) async {
    settings = next.sanitized();
    await storage.saveSettings(settings);
    ads.setPremium(settings.isPremium);
    await notifications.rescheduleAll(settings, items);
    notifyListeners();
  }

  Future<void> updateItem(PrepItem item) async {
    final sanitized = item.sanitized().copyWith();
    items = [
      for (final current in items)
        current.id == sanitized.id ? sanitized : current,
    ];
    await storage.saveItems(items);
    notifyListeners();
  }

  Future<void> completeItem(PrepItem item, {double? actualPrice}) async {
    final price = actualPrice ?? item.actualPrice;
    await updateItem(item.copyWith(
      isCompleted: true,
      actualPrice: price < 0 ? 0 : price,
      purchaseDate:
          price > 0 ? item.purchaseDate ?? DateTime.now() : item.purchaseDate,
      completedDate: DateTime.now(),
    ));
    analytics.itemCompleted(itemId: item.id);
    if (price > 0) analytics.priceAdded(itemId: item.id, price: price);
  }

  Future<void> uncompleteItem(PrepItem item) async {
    await updateItem(item.copyWith(
      isCompleted: false,
      clearCompletedDate: true,
    ));
  }

  Future<void> addOrUpdateGuest(Guest guest) async {
    final exists = guests.any((current) => current.id == guest.id);
    guests = exists
        ? [
            for (final current in guests)
              current.id == guest.id ? guest.sanitized() : current
          ]
        : [...guests, guest.sanitized()];
    await storage.saveGuests(guests);
    notifyListeners();
  }

  Future<void> addGuestsBulk(List<String> names) async {
    final cleanNames = names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    if (cleanNames.isEmpty) return;
    guests = [
      ...guests,
      for (final name in cleanNames)
        newGuest(
          name: name,
          side: GuestSide.common,
          status: GuestStatus.uncertain,
          personCount: 1,
        ),
    ];
    await storage.saveGuests(guests);
    notifyListeners();
  }

  Future<void> toggleGiftList(PrepItem item) async {
    await updateItem(item.copyWith(isGiftListed: !item.isGiftListed));
  }

  Future<void> addLead(LeadRequest lead) async {
    leads = [...leads, lead.sanitized()];
    await storage.saveLeads(leads);
    analytics.leadSubmitted(category: lead.category);
    notifyListeners();
  }

  Future<void> addCustomItem({
    required String title,
    required MainCategory category,
    required String subCategory,
    required ItemPriority priority,
    double estimatedPrice = 0,
  }) async {
    final now = DateTime.now();
    items = [
      ...items,
      PrepItem(
        id: _uuid.v4(),
        title: title,
        mainCategory: category,
        subCategory: subCategory,
        priority: priority,
        estimatedPrice: estimatedPrice < 0 ? 0 : estimatedPrice,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await storage.saveItems(items);
    notifyListeners();
  }

  Future<void> deleteItem(PrepItem item) async {
    await photoStorage.deleteItemPhotos(item.id);
    items = items.where((current) => current.id != item.id).toList();
    await storage.saveItems(items);
    notifyListeners();
  }

  Guest newGuest({
    required String name,
    String phone = '',
    GuestSide side = GuestSide.common,
    int personCount = 1,
    GuestStatus status = GuestStatus.uncertain,
    String note = '',
  }) {
    final now = DateTime.now();
    return Guest(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      side: side,
      guestCount: personCount,
      status: status,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> deleteGuest(Guest guest) async {
    guests = guests.where((current) => current.id != guest.id).toList();
    await storage.saveGuests(guests);
    notifyListeners();
  }

  Future<void> resetAll() async {
    await photoStorage.deleteAllItemPhotos();
    await storage.resetAll();
    settings = await storage.loadSettings();
    items = await storage.loadItems();
    guests = await storage.loadGuests();
    leads = await storage.loadLeads();
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> loadDemoData() async {
    await storage.loadDemoData();
    settings = await storage.loadSettings();
    items = await storage.loadItems();
    guests = await storage.loadGuests();
    leads = await storage.loadLeads();
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  String buildJsonBackup() {
    return ExportService().buildJsonBackup(
      settings: settings,
      items: items,
      guests: guests,
      leads: leads,
    );
  }

  Future<void> restoreJsonBackup(String raw) async {
    final backup = ExportService().parseJsonBackup(raw);
    settings = backup.settings.sanitized();
    items = backup.items.map((item) => item.sanitized()).toList();
    guests = backup.guests.map((guest) => guest.sanitized()).toList();
    leads = backup.leads.map((lead) => lead.sanitized()).toList();
    await storage.saveSettings(settings);
    await storage.saveItems(items);
    await storage.saveGuests(guests);
    await storage.saveLeads(leads);
    notifyListeners();
  }

  Future<void> purchasePremium(PremiumProduct product) async {
    settings = await premium.purchase(settings, product);
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    settings = await premium.restorePurchases(settings);
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }
}
