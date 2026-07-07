import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_items.dart';
import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';

class StorageService {
  static const _itemsKey = 'prep_items';
  static const _guestsKey = 'guests';
  static const _settingsKey = 'settings';

  Future<List<PrepItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null) {
      final seed = buildSeedItems();
      await saveItems(seed);
      return seed;
    }
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((item) => PrepItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveItems(List<PrepItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<List<Guest>> loadGuests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_guestsKey);
    if (raw == null) {
      final seed = buildDemoGuests();
      await saveGuests(seed);
      return seed;
    }
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((guest) => Guest.fromJson(guest as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGuests(List<Guest> guests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _guestsKey,
      jsonEncode(guests.map((guest) => guest.toJson()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) {
      final seed = buildDemoSettings();
      await saveSettings(seed);
      return seed;
    }
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
    await prefs.remove(_guestsKey);
    await prefs.remove(_settingsKey);
  }

  Future<void> resetToDemo() async {
    await saveItems(buildSeedItems());
    await saveGuests(buildDemoGuests());
    await saveSettings(buildDemoSettings());
  }
}
