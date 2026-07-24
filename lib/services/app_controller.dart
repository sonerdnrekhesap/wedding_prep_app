import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import 'ad_service.dart';
import 'photo_storage_service.dart';
import 'premium_service.dart';
import 'purchase_store.dart';
import 'storage_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.storage,
    required this.ads,
  });

  final StorageService storage;
  final AdService ads;
  final PhotoStorageService photoStorage = const PhotoStorageService();
  final _uuid = const Uuid();
  late final PremiumService premium = PremiumService(storage: storage);
  final PurchaseStore purchaseStore = PurchaseStore();

  bool isLoading = true;
  PurchaseStoreState purchaseState = PurchaseStoreState.initial;
  AppSettings settings = const AppSettings();
  List<PrepItem> items = [];
  List<Guest> guests = [];

  Future<void> load() async {
    await ads.initialize();
    settings = await storage.loadSettings();
    items = await storage.loadItems();
    guests = await storage.loadGuests();
    ads.setPremium(settings.isPremium);
    try {
      purchaseState = await purchaseStore.initialize(
        onEntitlement: (_) => _activatePremiumFromStore(),
        onState: (state) {
          purchaseState = state;
          notifyListeners();
        },
      );
    } catch (_) {
      purchaseState = const PurchaseStoreState(
        status: PurchaseStoreStatus.unavailable,
        message: 'Store satin alma servisi su an hazir degil.',
      );
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    purchaseStore.dispose();
    super.dispose();
  }

  Future<void> saveSettings(AppSettings next) async {
    settings = next;
    await storage.saveSettings(settings);
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> updateItem(PrepItem item) async {
    items = [
      for (final current in items) current.id == item.id ? item : current,
    ];
    await storage.saveItems(items);
    notifyListeners();
  }

  Future<void> completeItem(PrepItem item, {double? actualPrice}) async {
    await updateItem(item.copyWith(
      isCompleted: true,
      actualPrice: actualPrice ?? item.actualPrice,
      completedDate: DateTime.now(),
    ));
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
              current.id == guest.id ? guest : current
          ]
        : [...guests, guest];
    await storage.saveGuests(guests);
    notifyListeners();
  }

  Future<void> addCustomItem({
    required String title,
    required MainCategory category,
    required String subCategory,
    required ItemPriority priority,
    double estimatedPrice = 0,
    DateTime? targetPurchaseDate,
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
        estimatedPrice: estimatedPrice,
        purchaseDate: targetPurchaseDate,
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
    String tableName = '',
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
      tableName: tableName,
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
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> loadDemoData() async {
    await storage.loadDemoData();
    settings = await storage.loadSettings();
    items = await storage.loadItems();
    guests = await storage.loadGuests();
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> purchaseMockPremium(PremiumProduct product) async {
    settings = await premium.purchaseMock(settings, product);
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    if (purchaseState.canPurchase) {
      await purchaseStore.restore();
      return;
    }
    settings = await premium.restorePurchases(settings);
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }

  Future<void> purchasePremium(PremiumProduct product) async {
    final details = purchaseState.detailsFor(product);
    if (details == null) {
      purchaseState = purchaseState.copyWith(
        message: 'Bu premium urun henuz store tarafinda aktif degil.',
      );
      notifyListeners();
      return;
    }

    final started = await purchaseStore.buy(details);
    if (!started) {
      purchaseState = purchaseState.copyWith(
        status: PurchaseStoreStatus.failed,
        message: 'Satin alma baslatilamadi.',
      );
      notifyListeners();
    }
  }

  Future<void> _activatePremiumFromStore() async {
    settings = await premium.activateFromStore(settings);
    ads.setPremium(settings.isPremium);
    notifyListeners();
  }
}
